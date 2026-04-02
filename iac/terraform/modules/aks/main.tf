# AKS Cluster Module — Enterprise Grade
# Supports: private cluster, workload identity, multiple node pools,
# Azure CNI, Defender for Containers, Azure Policy add-on

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
  }
}

# ── Local Variables ───────────────────────────────────────────────────────────

locals {
  cluster_name = "aks-${var.workload}-${var.environment}-${var.location_short}"
  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "aks"
    Workload    = var.workload
  })
}

# ── Data Sources ──────────────────────────────────────────────────────────────

data "azurerm_client_config" "current" {}

data "azurerm_subnet" "aks" {
  name                 = var.aks_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.network_resource_group
}

data "azurerm_subnet" "pod" {
  name                 = var.pod_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.network_resource_group
}

# ── Log Analytics Workspace ───────────────────────────────────────────────────

resource "azurerm_log_analytics_workspace" "aks" {
  name                = "law-${local.cluster_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = local.common_tags
}

# ── AKS Cluster ───────────────────────────────────────────────────────────────

resource "azurerm_kubernetes_cluster" "main" {
  name                = local.cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = local.cluster_name
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  # Private cluster configuration
  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = false
  private_dns_zone_id                 = var.private_dns_zone_id

  # Automatic upgrades
  automatic_channel_upgrade           = "patch"
  node_os_channel_upgrade             = "NodeImage"
  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "02:00"
    utc_offset  = "+00:00"
  }

  # System node pool
  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_pool_vm_size
    node_count                   = var.system_node_pool_count
    vnet_subnet_id               = data.azurerm_subnet.aks.id
    pod_subnet_id                = data.azurerm_subnet.pod.id
    zones                        = ["1", "2", "3"]
    only_critical_addons_enabled = true
    os_disk_type                 = "Ephemeral"
    os_disk_size_gb              = 100

    upgrade_settings {
      max_surge = "33%"
    }

    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
    }
  }

  # Workload Identity
  workload_identity_enabled         = true
  oidc_issuer_enabled               = true

  # Azure AD Integration
  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  # Networking
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "calico"
    load_balancer_sku   = "standard"
    outbound_type       = "userDefinedRouting"
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
  }

  # Add-ons
  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.aks.id
    msi_auth_for_monitoring_enabled = true
  }

  azure_policy_enabled             = true
  http_application_routing_enabled = false

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Security
  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 48

  # Storage
  storage_profile {
    blob_driver_enabled         = true
    disk_driver_enabled         = true
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version,
    ]
  }
}

# ── Workload Node Pool ────────────────────────────────────────────────────────

resource "azurerm_kubernetes_cluster_node_pool" "workload" {
  name                  = "workload"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.workload_node_pool_vm_size
  vnet_subnet_id        = data.azurerm_subnet.aks.id
  pod_subnet_id         = data.azurerm_subnet.pod.id
  zones                 = ["1", "2", "3"]
  os_disk_type          = "Ephemeral"
  os_disk_size_gb       = 128

  auto_scaling_enabled = true
  min_count            = var.workload_node_pool_min
  max_count            = var.workload_node_pool_max

  node_labels = {
    "nodepool-type" = "workload"
    "environment"   = var.environment
  }

  node_taints = []

  upgrade_settings {
    max_surge = "33%"
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [node_count]
  }
}

# ── Spot Node Pool ────────────────────────────────────────────────────────────

resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.spot_node_pool_vm_size
  vnet_subnet_id        = data.azurerm_subnet.aks.id
  pod_subnet_id         = data.azurerm_subnet.pod.id
  zones                 = ["1", "2", "3"]
  priority              = "Spot"
  eviction_policy       = "Delete"
  spot_max_price        = -1
  os_disk_type          = "Ephemeral"
  os_disk_size_gb       = 128

  auto_scaling_enabled = true
  min_count            = 0
  max_count            = var.spot_node_pool_max

  node_labels = {
    "nodepool-type"                         = "spot"
    "environment"                           = var.environment
    "kubernetes.azure.com/scalesetpriority" = "spot"
  }

  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]

  upgrade_settings {
    max_surge = "33%"
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [node_count]
  }
}

# ── Diagnostic Settings ───────────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "diag-${local.cluster_name}"
  target_resource_id         = azurerm_kubernetes_cluster.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id

  enabled_log { category = "kube-apiserver" }
  enabled_log { category = "kube-controller-manager" }
  enabled_log { category = "kube-scheduler" }
  enabled_log { category = "kube-audit" }
  enabled_log { category = "kube-audit-admin" }
  enabled_log { category = "guard" }
  enabled_log { category = "cluster-autoscaler" }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
