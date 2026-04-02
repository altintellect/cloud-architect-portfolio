terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-prod"
    storage_account_name = "satfstateprod001"
    container_name       = "tfstate"
    key                  = "network/hub-spoke.tfstate"
  }
}

provider "azurerm" {
  features {}
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "location" {
  description = "Primary Azure region"
  type        = string
  default     = "canadacentral"
}

locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "hub" {
  name     = "rg-hub-network-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

output "hub_rg_id" {
  value = azurerm_resource_group.hub.id
}
