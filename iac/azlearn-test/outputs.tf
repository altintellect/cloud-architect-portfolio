# ============================================
# OUTPUTS
# After Terraform deploys your infrastructure
# these values get printed to the screen.
# Useful for seeing what was created and
# grabbing IDs/names for other tools.
# ============================================

# Shows the Resource Group name that was created
output "resource_group_name" {
  description = "Name of the created Resource Group"
  value       = azurerm_resource_group.azlearn.name
}

# Shows the Azure region where everything lives
output "resource_group_location" {
  description = "Location of the Resource Group"
  value       = azurerm_resource_group.azlearn.location
}

# Shows the full Virtual Network name
output "virtual_network_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.azlearn.name
}

# Shows the Subnet name
output "subnet_name" {
  description = "Name of the Subnet"
  value       = azurerm_subnet.azlearn.name
}

# Shows the Storage Account name
output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.azlearn.name
}

# Shows the full Azure resource ID of the storage account
# Used when other tools or scripts need to reference it
output "storage_account_id" {
  description = "Full Azure Resource ID of the Storage Account"
  value       = azurerm_storage_account.azlearn.id
}