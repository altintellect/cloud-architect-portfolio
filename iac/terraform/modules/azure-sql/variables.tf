# ── Required Variables ────────────────────────────────────────────────────────

variable "resource_group_name" {
  description = "Resource group for Azure SQL"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "location_short" {
  description = "Short location code (e.g. cac, cae)"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "workload" {
  description = "Workload name for resource naming"
  type        = string
}

variable "admin_username" {
  description = "SQL Server administrator username"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
}

variable "aad_admin_group_name" {
  description = "Azure AD admin group name for SQL Server"
  type        = string
}

variable "aad_admin_group_object_id" {
  description = "Azure AD admin group object ID"
  type        = string
}

variable "audit_storage_endpoint" {
  description = "Storage account endpoint for SQL audit logs"
  type        = string
}

# ── Optional Variables ────────────────────────────────────────────────────────

variable "sku_name" {
  description = "SQL Database SKU name"
  type        = string
  default     = "GP_Gen5_4"
}

variable "max_size_gb" {
  description = "Maximum database size in GB"
  type        = number
  default     = 256
}

variable "zone_redundant" {
  description = "Enable zone redundancy"
  type        = bool
  default     = true
}

variable "aad_auth_only" {
  description = "Allow only Azure AD authentication"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Short-term backup retention in days"
  type        = number
  default     = 35
  validation {
    condition     = var.backup_retention_days >= 7
    error_message = "Backup retention must be at least 7 days."
  }
}

variable "ltr_weekly_retention" {
  description = "Long-term weekly retention (ISO 8601 duration)"
  type        = string
  default     = "P4W"
}

variable "ltr_monthly_retention" {
  description = "Long-term monthly retention (ISO 8601 duration)"
  type        = string
  default     = "P12M"
}

variable "ltr_yearly_retention" {
  description = "Long-term yearly retention (ISO 8601 duration)"
  type        = string
  default     = "P5Y"
}

variable "allow_azure_services" {
  description = "Allow Azure services to access SQL Server"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for SQL Server"
  type        = string
  default     = null
}

variable "enable_geo_replication" {
  description = "Enable geo-replication to secondary region"
  type        = bool
  default     = false
}

variable "secondary_server_id" {
  description = "Secondary SQL Server resource ID for geo-replication"
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}
