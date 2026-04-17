# ============================================
# TERRAFORM CONFIGURATION
# ============================================
terraform {
  required_version = ">= 1.0"

  backend "azurerm" {
    resource_group_name  = "rg-altint-foundation"
    storage_account_name = "staltintfnd001ca"
    container_name       = "tfstate"
    key                  = "foundation.terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# ============================================
# AZURE PROVIDER
# ============================================
provider "azurerm" {
  features {}
}

# ============================================
# RESOURCE GROUP
# ============================================
resource "azurerm_resource_group" "foundation" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    project     = "altintellect"
    owner       = "altintellect"
    managed_by  = "terraform"
  }
}

# ============================================
# VIRTUAL NETWORK
# ============================================
resource "azurerm_virtual_network" "foundation" {
  name                = "vnet-altint-001"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.foundation.location
  resource_group_name = azurerm_resource_group.foundation.name

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ============================================
# SUBNET
# ============================================
resource "azurerm_subnet" "foundation" {
  name                 = "snet-altint-001"
  resource_group_name  = azurerm_resource_group.foundation.name
  virtual_network_name = azurerm_virtual_network.foundation.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ============================================
# STORAGE ACCOUNT
# ============================================
resource "azurerm_storage_account" "foundation" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.foundation.name
  location                 = azurerm_resource_group.foundation.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
