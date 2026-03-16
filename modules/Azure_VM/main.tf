
# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.localisation
}

# Virtual network 
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet
  address_space       = [var.vnet_adress_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet1
resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public-subnet]

} 

# public security group for ssh  
resource "azurerm_network_security_group" "public" {
  name                = "public_subnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public.id
} 

# Subnet2
resource "azurerm_subnet" "prive" {
  name                 = "prive-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.prive-subnet]
} 

# private security group : allow ssh from public-subnet
resource "azurerm_network_security_group" "prive" {
  name                = "prive_subnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = var.public-subnet
    destination_address_prefix = var.prive-subnet 
  }
}

resource "azurerm_subnet_network_security_group_association" "prive" {
  subnet_id                 = azurerm_subnet.prive.id
  network_security_group_id = azurerm_network_security_group.prive.id
} 

########### Virtual machine : public (with public ip adress) #########################################

resource "azurerm_linux_virtual_machine" "vm-public" {
  name                = var.vm_name-machine-public
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size-machine-public 
  admin_username      = var.admin_user_name
  network_interface_ids = [
    azurerm_network_interface.nic-public.id,
  ]

  admin_ssh_key {
    username   = var.admin_user_name
    public_key = file(var.ssh_public_key)
  }

  os_disk {
    name                 = "osdisk-public-vm"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12-arm64"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "pip-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static" 
  sku               = "Standard"
}

resource "azurerm_network_interface" "nic-public" {
  name                = "nic-public"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

########### Virtual machine : prive (without public ip adress) #########################################


resource "azurerm_linux_virtual_machine" "vm-prive" {
  name                = "node-${count.index + 1}"
  count               = var.count_vm-prive
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2pls_v6"
  admin_username      = var.admin_user_name
  network_interface_ids = [
    azurerm_network_interface.nic-prive[count.index].id,
  ]

admin_ssh_key {
    username   = var.admin_user_name
    public_key = file(var.ssh_public_key)
  }

  os_disk {
    name                 = "osdisk-node${count.index}" 
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-12"
    sku       = "12-arm64"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "nic-prive" {
  name                = "prive-nic-node${count.index + 1}"
  count               = var.count_vm-prive
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.prive.id
    private_ip_address_allocation = "Dynamic"
  }
}
