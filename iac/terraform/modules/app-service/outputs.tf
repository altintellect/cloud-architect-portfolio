output "app_service_id" {
  description = "App Service resource ID"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.main[0].id : null
}

output "app_service_name" {
  description = "App Service name"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.main[0].name : null
}

output "default_hostname" {
  description = "Default hostname of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.main[0].default_hostname : null
}

output "principal_id" {
  description = "Principal ID of the App Service managed identity"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.main[0].identity[0].principal_id : null
}

output "staging_slot_id" {
  description = "Staging slot resource ID"
  value       = var.enable_staging_slot && var.os_type == "Linux" ? azurerm_linux_web_app_slot.staging[0].id : null
}

output "service_plan_id" {
  description = "App Service Plan resource ID"
  value       = azurerm_service_plan.main.id
}
