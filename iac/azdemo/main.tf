# ============================================
# TERRAFORM CONFIGURATION
# ============================================
terraform {
  required_version = ">= 1.0"

  backend "azurerm" {
    resource_group_name  = "rg-azlearn-test"
    storage_account_name = "stazlearn001ca"
    container_name       = "tfstate"
    key                  = "azdemo.terraform.tfstate"
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
resource "azurerm_resource_group" "azdemo" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    project     = "azdemo"
    owner       = "acadianeng"
    managed_by  = "terraform"
  }
}

# ============================================
# VIRTUAL NETWORK
# ============================================
resource "azurerm_virtual_network" "azdemo" {
  name                = "vnet-azdemo-001"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.azdemo.location
  resource_group_name = azurerm_resource_group.azdemo.name

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ============================================
# SUBNET
# ============================================
resource "azurerm_subnet" "azdemo" {
  name                 = "snet-azdemo-001"
  resource_group_name  = azurerm_resource_group.azdemo.name
  virtual_network_name = azurerm_virtual_network.azdemo.name
  address_prefixes     = ["10.1.1.0/24"]
}

# ============================================
# STORAGE ACCOUNT
# ============================================
resource "azurerm_storage_account" "azdemo" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.azdemo.name
  location                 = azurerm_resource_group.azdemo.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ============================================
# PUBLIC IP
# Gives the VM a public address so you
# can connect to it from your computer
# ============================================
resource "azurerm_public_ip" "azdemo" {
  name                = "pip-azdemo-001"
  location            = azurerm_resource_group.azdemo.location
  resource_group_name = azurerm_resource_group.azdemo.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ============================================
# NETWORK INTERFACE
# Connects the VM to the subnet and public IP
# Like a network card in a physical computer
# ============================================
resource "azurerm_network_interface" "azdemo" {
  name                = "nic-azdemo-001"
  location            = azurerm_resource_group.azdemo.location
  resource_group_name = azurerm_resource_group.azdemo.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.azdemo.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.azdemo.id
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ============================================
# VIRTUAL MACHINE
# Ubuntu 22.04 LTS - smallest size B1s
# 1 vCPU, 1GB RAM - perfect for learning
# ============================================
resource "azurerm_linux_virtual_machine" "azdemo" {
  name                = "vm-azdemo-001"
  resource_group_name = azurerm_resource_group.azdemo.name
  location            = azurerm_resource_group.azdemo.location
  size                = "Standard_B2als_v2"
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.azdemo.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}