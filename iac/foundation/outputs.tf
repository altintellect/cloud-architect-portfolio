# ============================================
# OUTPUTS
# ============================================

output "resource_group_name" {
  description = "Name of the created Resource Group"
  value       = azurerm_resource_group.foundation.name
}

output "resource_group_location" {
  description = "Location of the Resource Group"
  value       = azurerm_resource_group.foundation.location
}

output "virtual_network_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.foundation.name
}

output "subnet_name" {
  description = "Name of the Subnet"
  value       = azurerm_subnet.foundation.name
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.foundation.name
}

output "storage_account_id" {
  description = "Full Azure Resource ID of the Storage Account"
  value       = azurerm_storage_account.foundation.id
}