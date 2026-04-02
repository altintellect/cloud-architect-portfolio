# ── Required Variables ────────────────────────────────────────────────────────

variable "resource_group_name" {
  description = "Resource group for App Service"
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

# ── Optional Variables ────────────────────────────────────────────────────────

variable "os_type" {
  description = "Operating system type (Linux or Windows)"
  type        = string
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be Linux or Windows."
  }
}

variable "sku_name" {
  description = "App Service Plan SKU"
  type        = string
  default     = "P2v3"
}

variable "always_on" {
  description = "Keep app always on"
  type        = bool
  default     = true
}

variable "stack_type" {
  description = "Application stack type (docker, dotnet, python, node)"
  type        = string
  default     = "docker"
}

variable "docker_image_name" {
  description = "Docker image name"
  type        = string
  default     = ""
}

variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "docker_registry_url" {
  description = "Docker registry URL"
  type        = string
  default     = ""
}

variable "dotnet_version" {
  description = ".NET version"
  type        = string
  default     = "8.0"
}

variable "python_version" {
  description = "Python version"
  type        = string
  default     = "3.12"
}

variable "node_version" {
  description = "Node.js version"
  type        = string
  default     = "20-lts"
}

variable "app_settings" {
  description = "Application settings (environment variables)"
  type        = map(string)
  default     = {}
}

variable "app_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_staging_slot" {
  description = "Enable staging deployment slot"
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "Subnet ID for VNet integration"
  type        = string
  default     = null
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for App Service"
  type        = string
  default     = null
}

variable "enable_autoscale" {
  description = "Enable autoscaling"
  type        = bool
  default     = true
}

variable "autoscale_min" {
  description = "Minimum instance count for autoscaling"
  type        = number
  default     = 2
}

variable "autoscale_max" {
  description = "Maximum instance count for autoscaling"
  type        = number
  default     = 10
}

variable "autoscale_default" {
  description = "Default instance count for autoscaling"
  type        = number
  default     = 2
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
