# ============================================
# VARIABLES
# These are like parameters/inputs for your
# Terraform code. Instead of hardcoding values
# in main.tf, we define them here and set
# actual values in terraform.tfvars
# ============================================

# Which Azure region to deploy to
variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "canadacentral"
}

# Name of the Resource Group
variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-azlearn-test"
}

# Environment tag (test, dev, prod)
variable "environment" {
  description = "Environment name used for tagging resources"
  type        = string
  default     = "test"
}

# Storage account name - must be globally unique
# Only lowercase letters and numbers, 3-24 chars
variable "storage_account_name" {
  description = "Name of the Azure Storage Account - must be globally unique"
  type        = string
  default     = "stazlearn001ca"
}