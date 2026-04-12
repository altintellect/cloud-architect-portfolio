# ============================================
# TERRAFORM CONFIGURATION
# Tells Terraform which version to use and
# which cloud provider plugin to download
# ============================================
terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# ============================================
# AZURE PROVIDER
# Tells Terraform to use Azure as the cloud
# Credentials come from GitHub Secrets
# ============================================
provider "azurerm" {
  features {}
}

# ============================================
# RESOURCE GROUP
# A container that holds all your Azure resources
# Like a folder for your cloud infrastructure
# ============================================
resource "azurerm_resource_group" "azlearn" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    project     = "azlearn"
    owner       = "acadianeng"
    managed_by  = "terraform"
  }
}

# ============================================
# VIRTUAL NETWORK
# Your private network in Azure
# Like a private office network in the cloud
# ============================================
resource "azurerm_virtual_network" "azlearn" {
  name                = "vnet-azlearn-001"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azlearn.location
  resource_group_name = azurerm_resource_group.azlearn.name

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ============================================
# SUBNET
# A smaller network inside your VNet
# Where your resources actually live
# ============================================
resource "azurerm_subnet" "azlearn" {
  name                 = "snet-azlearn-001"
  resource_group_name  = azurerm_resource_group.azlearn.name
  virtual_network_name = azurerm_virtual_network.azlearn.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ============================================
# STORAGE ACCOUNT
# Cheap Azure storage - good for learning
# Costs ~$2 CAD/month
# ============================================
resource "azurerm_storage_account" "azlearn" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.azlearn.name
  location                 = azurerm_resource_group.azlearn.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
