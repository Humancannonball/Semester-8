resource "random_id" "suffix" {
  byte_length = 3
}

resource "azurerm_resource_group" "site_a" {
  name     = var.site_a_resource_group_name
  location = var.site_a_location

  tags = {
    ENV  = "VPN"
    SITE = "A"
  }
}

resource "azurerm_resource_group" "site_b" {
  name     = var.site_b_resource_group_name
  location = var.site_b_location

  tags = {
    ENV  = "VPN"
    SITE = "B"
  }
}

resource "azurerm_virtual_network" "site_a" {
  name                = "mark-vpn-a-vnet"
  location            = azurerm_resource_group.site_a.location
  resource_group_name = azurerm_resource_group.site_a.name
  address_space       = [var.site_a_address_space]

  tags = {
    ENV  = "VPN"
    SITE = "A"
  }
}

resource "azurerm_virtual_network" "site_b" {
  name                = "mark-vpn-b-vnet"
  location            = azurerm_resource_group.site_b.location
  resource_group_name = azurerm_resource_group.site_b.name
  address_space       = [var.site_b_address_space]

  tags = {
    ENV  = "VPN"
    SITE = "B"
  }
}

resource "azurerm_subnet" "site_a_vm" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.site_a.name
  virtual_network_name = azurerm_virtual_network.site_a.name
  address_prefixes     = [var.site_a_vm_subnet]
}

resource "azurerm_subnet" "site_b_vm" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.site_b.name
  virtual_network_name = azurerm_virtual_network.site_b.name
  address_prefixes     = [var.site_b_vm_subnet]
}

resource "azurerm_subnet" "site_a_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.site_a.name
  virtual_network_name = azurerm_virtual_network.site_a.name
  address_prefixes     = [var.site_a_gateway_subnet]
}

resource "azurerm_subnet" "site_b_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.site_b.name
  virtual_network_name = azurerm_virtual_network.site_b.name
  address_prefixes     = [var.site_b_gateway_subnet]
}

resource "azurerm_network_security_group" "site_a_vm" {
  name                = "mark-vpn-a-nsg"
  location            = azurerm_resource_group.site_a.location
  resource_group_name = azurerm_resource_group.site_a.name

  security_rule {
    name                       = "Allow-ICMP-From-Site-B"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.site_b_address_space
    destination_address_prefix = "*"
  }

  tags = {
    ENV  = "VPN"
    SITE = "A"
  }
}

resource "azurerm_network_security_group" "site_b_vm" {
  name                = "mark-vpn-b-nsg"
  location            = azurerm_resource_group.site_b.location
  resource_group_name = azurerm_resource_group.site_b.name

  security_rule {
    name                       = "Allow-ICMP-From-Site-A"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.site_a_address_space
    destination_address_prefix = "*"
  }

  tags = {
    ENV  = "VPN"
    SITE = "B"
  }
}

resource "azurerm_subnet_network_security_group_association" "site_a_vm" {
  subnet_id                 = azurerm_subnet.site_a_vm.id
  network_security_group_id = azurerm_network_security_group.site_a_vm.id
}

resource "azurerm_subnet_network_security_group_association" "site_b_vm" {
  subnet_id                 = azurerm_subnet.site_b_vm.id
  network_security_group_id = azurerm_network_security_group.site_b_vm.id
}

resource "azurerm_public_ip" "site_a_gateway" {
  name                = "mark-vpn-a-gateway-pip"
  location            = azurerm_resource_group.site_a.location
  resource_group_name = azurerm_resource_group.site_a.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = {
    ENV  = "VPN"
    SITE = "A"
  }
}

resource "azurerm_public_ip" "site_b_gateway" {
  name                = "mark-vpn-b-gateway-pip"
  location            = azurerm_resource_group.site_b.location
  resource_group_name = azurerm_resource_group.site_b.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = {
    ENV  = "VPN"
    SITE = "B"
  }
}

resource "azurerm_virtual_network_gateway" "site_a" {
  name                = "mark-vpn-a-gateway"
  location            = azurerm_resource_group.site_a.location
  resource_group_name = azurerm_resource_group.site_a.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = var.vpn_gateway_sku
  active_active       = false
  enable_bgp          = false

  ip_configuration {
    name                          = "gateway-ipconfig"
    public_ip_address_id          = azurerm_public_ip.site_a_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.site_a_gateway.id
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.site_a_vm,
    azurerm_linux_virtual_machine.site_a,
  ]

  tags = {
    ENV  = "VPN"
    SITE = "A"
  }
}

resource "azurerm_virtual_network_gateway" "site_b" {
  name                = "mark-vpn-b-gateway"
  location            = azurerm_resource_group.site_b.location
  resource_group_name = azurerm_resource_group.site_b.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = var.vpn_gateway_sku
  active_active       = false
  enable_bgp          = false

  ip_configuration {
    name                          = "gateway-ipconfig"
    public_ip_address_id          = azurerm_public_ip.site_b_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.site_b_gateway.id
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.site_b_vm,
    azurerm_linux_virtual_machine.site_b,
  ]

  tags = {
    ENV  = "VPN"
    SITE = "B"
  }
}

resource "azurerm_local_network_gateway" "site_a_remote" {
  name                = "mark-vpn-a-lng"
  location            = azurerm_resource_group.site_a.location
  resource_group_name = azurerm_resource_group.site_a.name
  gateway_address     = azurerm_public_ip.site_b_gateway.ip_address
  address_space       = [var.site_b_address_space]

  depends_on = [
    azurerm_virtual_network_gateway.site_b,
  ]

  tags = {
    ENV  = "VPN"
    SITE = "A"
  }
}

resource "azurerm_local_network_gateway" "site_b_remote" {
  name                = "mark-vpn-b-lng"
  location            = azurerm_resource_group.site_b.location
  resource_group_name = azurerm_resource_group.site_b.name
  gateway_address     = azurerm_public_ip.site_a_gateway.ip_address
  address_space       = [var.site_a_address_space]

  depends_on = [
    azurerm_virtual_network_gateway.site_a,
  ]

  tags = {
    ENV  = "VPN"
    SITE = "B"
  }
}

resource "azurerm_virtual_network_gateway_connection" "site_a_to_b" {
  name                       = "mark-vpn-a-to-b"
  location                   = azurerm_resource_group.site_a.location
  resource_group_name        = azurerm_resource_group.site_a.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.site_a.id
  local_network_gateway_id   = azurerm_local_network_gateway.site_a_remote.id
  shared_key                 = var.vpn_shared_key
  connection_protocol        = "IKEv2"
  enable_bgp                 = false

  tags = {
    ENV  = "VPN"
    SITE = "A"
  }
}

resource "azurerm_virtual_network_gateway_connection" "site_b_to_a" {
  name                       = "mark-vpn-b-to-a"
  location                   = azurerm_resource_group.site_b.location
  resource_group_name        = azurerm_resource_group.site_b.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.site_b.id
  local_network_gateway_id   = azurerm_local_network_gateway.site_b_remote.id
  shared_key                 = var.vpn_shared_key
  connection_protocol        = "IKEv2"
  enable_bgp                 = false

  tags = {
    ENV  = "VPN"
    SITE = "B"
  }
}

resource "azurerm_network_interface" "site_a_vm" {
  name                = "mark-vpn-a-vm-nic"
  location            = azurerm_resource_group.site_a.location
  resource_group_name = azurerm_resource_group.site_a.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.site_a_vm.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    ENV  = "VPN"
    SITE = "A"
  }
}

resource "azurerm_network_interface" "site_b_vm" {
  name                = "mark-vpn-b-vm-nic"
  location            = azurerm_resource_group.site_b.location
  resource_group_name = azurerm_resource_group.site_b.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.site_b_vm.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    ENV  = "VPN"
    SITE = "B"
  }
}

resource "azurerm_linux_virtual_machine" "site_a" {
  name                            = "mark-vpn-a-vm"
  resource_group_name             = azurerm_resource_group.site_a.name
  location                        = azurerm_resource_group.site_a.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.site_a_vm.id]

  os_disk {
    name                 = "mark-vpn-a-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = filebase64("${path.module}/cloud-init.yaml")

  tags = {
    ENV  = "VPN"
    SITE = "A"
  }
}

resource "azurerm_linux_virtual_machine" "site_b" {
  name                            = "mark-vpn-b-vm"
  resource_group_name             = azurerm_resource_group.site_b.name
  location                        = azurerm_resource_group.site_b.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.site_b_vm.id]

  os_disk {
    name                 = "mark-vpn-b-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = filebase64("${path.module}/cloud-init.yaml")

  tags = {
    ENV  = "VPN"
    SITE = "B"
  }
}
