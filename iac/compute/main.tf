# ============================================
# TERRAFORM CONFIGURATION
# ============================================
terraform {
  required_version = ">= 1.0"

  backend "azurerm" {
    resource_group_name  = "rg-altint-foundation"
    storage_account_name = "staltintfnd001ca"
    container_name       = "tfstate"
    key                  = "compute.terraform.tfstate"
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
resource "azurerm_resource_group" "compute" {
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
resource "azurerm_virtual_network" "compute" {
  name                = "vnet-altint-compute-001"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ============================================
# SUBNET
# ============================================
resource "azurerm_subnet" "compute" {
  name                 = "snet-altint-compute-001"
  resource_group_name  = azurerm_resource_group.compute.name
  virtual_network_name = azurerm_virtual_network.compute.name
  address_prefixes     = ["10.1.1.0/24"]
}

# ============================================
# STORAGE ACCOUNT
# ============================================
resource "azurerm_storage_account" "compute" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.compute.name
  location                 = azurerm_resource_group.compute.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ============================================
# NETWORK SECURITY GROUP
# ============================================
resource "azurerm_network_security_group" "compute" {
  name                = "nsg-altint-compute-001"
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_ip
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ============================================
# NSG ASSOCIATION
# ============================================
resource "azurerm_subnet_network_security_group_association" "compute" {
  subnet_id                 = azurerm_subnet.compute.id
  network_security_group_id = azurerm_network_security_group.compute.id
}

# ============================================
# PUBLIC IP
# ============================================
resource "azurerm_public_ip" "compute" {
  name                = "pip-altint-compute-001"
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ============================================
# NETWORK INTERFACE
# ============================================
resource "azurerm_network_interface" "compute" {
  name                = "nic-altint-compute-001"
  location            = azurerm_resource_group.compute.location
  resource_group_name = azurerm_resource_group.compute.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.compute.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.compute.id
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# ============================================
# VIRTUAL MACHINE
# Ubuntu 22.04 LTS - Standard_B2als_v2
# ============================================
resource "azurerm_linux_virtual_machine" "compute" {
  name                = "vm-altint-001"
  resource_group_name = azurerm_resource_group.compute.name
  location            = azurerm_resource_group.compute.location
  size                = "Standard_B2als_v2"
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.compute.id
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