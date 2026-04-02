# ── Required Variables ────────────────────────────────────────────────────────

variable "resource_group_name" {
  description = "Name of the resource group where AKS will be deployed"
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
}

variable "location_short" {
  description = "Short location code used in resource naming (e.g. cac, cae)"
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
  description = "Workload name used in resource naming"
  type        = string
}

variable "vnet_name" {
  description = "Name of the VNet where AKS subnets reside"
  type        = string
}

variable "network_resource_group" {
  description = "Resource group containing the VNet"
  type        = string
}

variable "aks_subnet_name" {
  description = "Name of the subnet for AKS nodes"
  type        = string
}

variable "pod_subnet_name" {
  description = "Name of the subnet for AKS pods (Azure CNI overlay)"
  type        = string
}

variable "admin_group_object_ids" {
  description = "List of Azure AD group object IDs with AKS admin access"
  type        = list(string)
}

variable "private_dns_zone_id" {
  description = "Resource ID of the private DNS zone for AKS private cluster"
  type        = string
}

# ── Optional Variables ────────────────────────────────────────────────────────

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.29"
}

variable "sku_tier" {
  description = "AKS SKU tier (Free, Standard, Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "SKU tier must be Free, Standard, or Premium."
  }
}

variable "system_node_pool_vm_size" {
  description = "VM size for the system node pool"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "system_node_pool_count" {
  description = "Number of nodes in the system node pool"
  type        = number
  default     = 3
  validation {
    condition     = var.system_node_pool_count >= 3
    error_message = "System node pool must have at least 3 nodes for HA."
  }
}

variable "workload_node_pool_vm_size" {
  description = "VM size for the workload node pool"
  type        = string
  default     = "Standard_D8s_v5"
}

variable "workload_node_pool_min" {
  description = "Minimum number of nodes in the workload node pool"
  type        = number
  default     = 3
}

variable "workload_node_pool_max" {
  description = "Maximum number of nodes in the workload node pool"
  type        = number
  default     = 10
}

variable "spot_node_pool_vm_size" {
  description = "VM size for the spot node pool"
  type        = string
  default     = "Standard_D8s_v5"
}

variable "spot_node_pool_max" {
  description = "Maximum number of nodes in the spot node pool"
  type        = number
  default     = 20
}

variable "service_cidr" {
  description = "CIDR range for Kubernetes services"
  type        = string
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address for Kubernetes DNS service"
  type        = string
  default     = "172.16.0.10"
}

variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics"
  type        = number
  default     = 90
  validation {
    condition     = var.log_retention_days >= 30
    error_message = "Log retention must be at least 30 days."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
