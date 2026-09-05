terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Resource Group
resource "azurerm_resource_group" "example" {
  name     = "my-first-rg"
  location = "Central India"
}

# 2. Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = "my-vnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  address_space = ["10.0.0.0/16"]
}

# 3. Subnet
resource "azurerm_subnet" "example" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name

  address_prefixes = ["10.0.1.0/24"]
}

# 4. Network Interface
resource "azurerm_network_interface" "example" {
  name                = "my-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 5. Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "example" {
  name                = "my-first-vm"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  size           = "Standard_B2ts_v2"
  admin_username = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.example.id
  ]

  admin_password                  = "admin@123"
  disable_password_authentication = false

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
}