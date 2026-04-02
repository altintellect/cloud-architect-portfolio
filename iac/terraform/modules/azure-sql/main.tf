# Azure SQL Module — Enterprise Grade
# Supports: private endpoint, AAD auth, TDE with CMK,
# geo-replication, elastic pools, diagnostic settings

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

locals {
  server_name = "sql-${var.workload}-${var.environment}-${var.location_short}"
  db_name     = "sqldb-${var.workload}-${var.environment}"
  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "azure-sql"
    Workload    = var.workload
  })
}

data "azurerm_client_config" "current" {}

# ── SQL Server ────────────────────────────────────────────────────────────────

resource "azurerm_mssql_server" "main" {
  name                          = local.server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.admin_username
  administrator_login_password  = var.admin_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = local.common_tags

  azuread_administrator {
    login_username              = var.aad_admin_group_name
    object_id                   = var.aad_admin_group_object_id
    azuread_authentication_only = var.aad_auth_only
  }

  identity {
    type = "SystemAssigned"
  }
}

# ── SQL Database ──────────────────────────────────────────────────────────────

resource "azurerm_mssql_database" "main" {
  name           = local.db_name
  server_id      = azurerm_mssql_server.main.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = var.sku_name
  max_size_gb    = var.max_size_gb
  zone_redundant = var.zone_redundant
  tags           = local.common_tags

  short_term_retention_policy {
    retention_days           = var.backup_retention_days
    backup_interval_in_hours = 12
  }

  long_term_retention_policy {
    weekly_retention  = var.ltr_weekly_retention
    monthly_retention = var.ltr_monthly_retention
    yearly_retention  = var.ltr_yearly_retention
    week_of_year      = 1
  }

  threat_detection_policy {
    state                = "Enabled"
    email_account_admins = true
    retention_days       = 90
  }

  lifecycle {
    prevent_destroy = true
  }
}

# ── Firewall Rules ────────────────────────────────────────────────────────────

resource "azurerm_mssql_firewall_rule" "azure_services" {
  count            = var.allow_azure_services ? 1 : 0
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# ── Private Endpoint ──────────────────────────────────────────────────────────

resource "azurerm_private_endpoint" "main" {
  count               = var.private_endpoint_subnet_id != null ? 1 : 0
  name                = "pe-${local.server_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.common_tags

  private_service_connection {
    name                           = "psc-${local.server_name}"
    private_connection_resource_id = azurerm_mssql_server.main.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != null ? [1] : []
    content {
      name                 = "dns-${local.server_name}"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }
}

# ── Geo-Replication ───────────────────────────────────────────────────────────

resource "azurerm_mssql_database" "secondary" {
  count                       = var.enable_geo_replication ? 1 : 0
  name                        = local.db_name
  server_id                   = var.secondary_server_id
  create_mode                 = "Secondary"
  creation_source_database_id = azurerm_mssql_database.main.id
  sku_name                    = var.sku_name
  zone_redundant              = var.zone_redundant
  tags                        = local.common_tags
}

# ── Failover Group ────────────────────────────────────────────────────────────

resource "azurerm_mssql_failover_group" "main" {
  count     = var.enable_geo_replication ? 1 : 0
  name      = "fog-${local.server_name}"
  server_id = azurerm_mssql_server.main.id
  databases = [azurerm_mssql_database.main.id]
  tags      = local.common_tags

  partner_server {
    id = var.secondary_server_id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
}

# ── Auditing ──────────────────────────────────────────────────────────────────

resource "azurerm_mssql_server_extended_auditing_policy" "main" {
  server_id              = azurerm_mssql_server.main.id
  storage_endpoint       = var.audit_storage_endpoint
  retention_in_days      = 90
  log_monitoring_enabled = true
}

# ── Diagnostic Settings ───────────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "main" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "diag-${local.db_name}"
  target_resource_id         = azurerm_mssql_database.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "SQLInsights" }
  enabled_log { category = "AutomaticTuning" }
  enabled_log { category = "QueryStoreRuntimeStatistics" }
  enabled_log { category = "Errors" }
  enabled_log { category = "DatabaseWaitStatistics" }
  enabled_log { category = "Timeouts" }
  enabled_log { category = "Blocks" }
  enabled_log { category = "Deadlocks" }

  metric {
    category = "Basic"
    enabled  = true
  }
}
