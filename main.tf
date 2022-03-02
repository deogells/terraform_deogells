terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.98.0"
    }
  }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "deogells" {
  name     = "deogells-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "deogells" {
  name                = "deogells-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.deogells.location
  resource_group_name = azurerm_resource_group.deogells.name
}

resource "azurerm_subnet" "deogells" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.deogells.name
  virtual_network_name = azurerm_virtual_network.deogells.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_public_ip" "deogells" {
  name                = "acesso_publico"
  resource_group_name = azurerm_resource_group.deogells.name
  location            = azurerm_resource_group.deogells.location
  allocation_method   = "Static"
tags = {
    environment = "deogells"
}
}

resource "azurerm_network_interface" "deogells" {
  name                = "deogells-nic"
  location            = azurerm_resource_group.deogells.location
  resource_group_name = azurerm_resource_group.deogells.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.deogells.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.deogells.id
  }
}

resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = "workspace"
  location            = azurerm_resource_group.deogells.location
  resource_group_name = azurerm_resource_group.deogells.name

  friendly_name = "Acesso_RDP"
  description   = "A description of my workspace"
}

resource "azurerm_windows_virtual_machine" "deogells" {
  name                = "deogells-vm"
  resource_group_name = azurerm_resource_group.deogells.name
  location            = azurerm_resource_group.deogells.location
  size                = "Standard_F2"
  admin_username      = "deogells"
  admin_password      = "N0r0nh4$2019"
  network_interface_ids = [azurerm_network_interface.deogells.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  winrm_listener {
    protocol = http
    }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  

}