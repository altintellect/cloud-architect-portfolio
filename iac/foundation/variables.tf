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
  default     = "rg-altint-foundation"
}

variable "environment" {
  description = "Environment name used for tagging resources"
  type        = string
  default     = "production"
}

variable "storage_account_name" {
  description = "Name of the Azure Storage Account - must be globally unique"
  type        = string
  default     = "staltintfnd001ca"
}