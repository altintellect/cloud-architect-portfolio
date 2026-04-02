output "server_id" {
  description = "Azure SQL Server resource ID"
  value       = azurerm_mssql_server.main.id
}

output "server_name" {
  description = "Azure SQL Server name"
  value       = azurerm_mssql_server.main.name
}

output "server_fqdn" {
  description = "Azure SQL Server fully qualified domain name"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "database_id" {
  description = "Azure SQL Database resource ID"
  value       = azurerm_mssql_database.main.id
}

output "database_name" {
  description = "Azure SQL Database name"
  value       = azurerm_mssql_database.main.name
}

output "server_principal_id" {
  description = "Principal ID of SQL Server managed identity"
  value       = azurerm_mssql_server.main.identity[0].principal_id
}

output "failover_group_id" {
  description = "Failover group resource ID"
  value       = var.enable_geo_replication ? azurerm_mssql_failover_group.main[0].id : null
}
