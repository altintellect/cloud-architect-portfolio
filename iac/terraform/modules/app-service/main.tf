# App Service Module — Enterprise Grade
# Supports: Linux/Windows, deployment slots, VNet integration,
# private endpoints, managed identity, autoscaling

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

locals {
  app_name  = "app-${var.workload}-${var.environment}-${var.location_short}"
  plan_name = "asp-${var.workload}-${var.environment}-${var.location_short}"
  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "app-service"
    Workload    = var.workload
  })
}

# ── App Service Plan ──────────────────────────────────────────────────────────

resource "azurerm_service_plan" "main" {
  name                = local.plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku_name
  tags                = local.common_tags
}

# ── App Service ───────────────────────────────────────────────────────────────

resource "azurerm_linux_web_app" "main" {
  count = var.os_type == "Linux" ? 1 : 0

  name                = local.app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true

  site_config {
    always_on              = var.always_on
    minimum_tls_version    = "1.2"
    http2_enabled          = true
    vnet_route_all_enabled = true

    application_stack {
      dynamic "docker" {
        for_each = var.stack_type == "docker" ? [1] : []
        content {
          image_name   = var.docker_image_name
          image_tag    = var.docker_image_tag
          registry_url = var.docker_registry_url
        }
      }
      dynamic "dotnet" {
        for_each = var.stack_type == "dotnet" ? [1] : []
        content {
          dotnet_version = var.dotnet_version
        }
      }
      dynamic "python" {
        for_each = var.stack_type == "python" ? [1] : []
        content {
          python_version = var.python_version
        }
      }
      dynamic "node" {
        for_each = var.stack_type == "node" ? [1] : []
        content {
          node_version = var.node_version
        }
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = merge(var.app_settings, {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE   = "false"
    APPLICATIONINSIGHTS_CONNECTION_STRING = var.app_insights_connection_string
  })

  logs {
    application_logs {
      file_system_level = "Warning"
    }
    http_logs {
      retention_in_days {
        retention_in_days = 7
      }
    }
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
    ]
  }
}

# ── Deployment Slot (Staging) ─────────────────────────────────────────────────

resource "azurerm_linux_web_app_slot" "staging" {
  count = var.os_type == "Linux" && var.enable_staging_slot ? 1 : 0

  name           = "staging"
  app_service_id = azurerm_linux_web_app.main[0].id
  https_only     = true

  site_config {
    always_on              = false
    minimum_tls_version    = "1.2"
    http2_enabled          = true
    vnet_route_all_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = var.app_settings
  tags         = local.common_tags
}

# ── VNet Integration ──────────────────────────────────────────────────────────

resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  count          = var.subnet_id != null ? 1 : 0
  app_service_id = var.os_type == "Linux" ? azurerm_linux_web_app.main[0].id : null
  subnet_id      = var.subnet_id
}

# ── Private Endpoint ──────────────────────────────────────────────────────────

resource "azurerm_private_endpoint" "main" {
  count               = var.private_endpoint_subnet_id != null ? 1 : 0
  name                = "pe-${local.app_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id
  tags                = local.common_tags

  private_service_connection {
    name                           = "psc-${local.app_name}"
    private_connection_resource_id = var.os_type == "Linux" ? azurerm_linux_web_app.main[0].id : null
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != null ? [1] : []
    content {
      name                 = "dns-${local.app_name}"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }
}

# ── Autoscale Settings ────────────────────────────────────────────────────────

resource "azurerm_monitor_autoscale_setting" "main" {
  count               = var.enable_autoscale ? 1 : 0
  name                = "autoscale-${local.plan_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_service_plan.main.id
  tags                = local.common_tags

  profile {
    name = "default"
    capacity {
      default = var.autoscale_default
      minimum = var.autoscale_min
      maximum = var.autoscale_max
    }
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }
  }
}

# ── Diagnostic Settings ───────────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "main" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "diag-${local.app_name}"
  target_resource_id         = var.os_type == "Linux" ? azurerm_linux_web_app.main[0].id : null
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "AppServiceHTTPLogs" }
  enabled_log { category = "AppServiceConsoleLogs" }
  enabled_log { category = "AppServiceAppLogs" }
  enabled_log { category = "AppServiceAuditLogs" }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
