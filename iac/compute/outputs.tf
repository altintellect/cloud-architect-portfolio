# ============================================
# OUTPUTS
# ============================================

output "resource_group_name" {
  description = "Name of the created Resource Group"
  value       = azurerm_resource_group.compute.name
}

output "resource_group_location" {
  description = "Location of the Resource Group"
  value       = azurerm_resource_group.compute.location
}

output "virtual_network_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.compute.name
}

output "subnet_name" {
  description = "Name of the Subnet"
  value       = azurerm_subnet.compute.name
}

output "storage_account_name" {
  description = "Name of the Storage Account"
  value       = azurerm_storage_account.compute.name
}

output "public_ip_address" {
  description = "Public IP address of the Virtual Machine"
  value       = azurerm_public_ip.compute.ip_address
}

output "vm_name" {
  description = "Name of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.compute.name
}

output "vm_admin_username" {
  description = "Admin username for the Virtual Machine"
  value       = azurerm_linux_virtual_machine.compute.admin_username
}