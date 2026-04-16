# ============================================
# VARIABLES
# ============================================

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "canadacentral"
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-azdemo-test"
}

variable "environment" {
  description = "Environment name used for tagging resources"
  type        = string
  default     = "test"
}

variable "storage_account_name" {
  description = "Name of the Azure Storage Account - must be globally unique"
  type        = string
  default     = "stazdemo001ca"
}

variable "vm_admin_username" {
  description = "Admin username for the Virtual Machine"
  type        = string
  default     = "azdemoadmin"
}

variable "vm_admin_password" {
  description = "Admin password for the Virtual Machine"
  type        = string
  sensitive   = true
}