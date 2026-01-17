  resource "azurerm_resource_group" "rg"{
  name     = "terraform"
  location = "eastus"
}


resource "azurerm_virtual_network" "terra_vm_network" {
  for_each = {
    finance   = ["10.0.0.0/12", "10.16.0.0/12"]
    logistics = ["192.168.0.0/16"]
    marketing = ["172.16.0.0/16", "172.17.0.0/16"]
  }

  name                = each.key
  location            = "eastus"
  resource_group_name = "terraform"
  address_space       = each.value

}


resource "azurerm_subnet" "name" {
  for_each = {
    finance   = ["10.0.0.0/24"]
    logistics = ["192.168.0.0/24"]
    marketing = ["172.17.0.0/24"]
  }
  name                 = "terrasubnet"
  resource_group_name  = "terraform"
  virtual_network_name = azurerm_virtual_network.terra_vm_network[each.key].name
  address_prefixes     = each.value
}


resource "azurerm_network_interface" "example" {
  for_each            = toset(["finance", "logistics",  "marketing"])
  name                = "${each.value}-nic"
  location            = "eastus"
  resource_group_name = "terraform"

  ip_configuration {
    name                          = "sur-01"
    subnet_id                     = azurerm_subnet.name[each.value].id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }

}

resource "azurerm_network_security_group" "terra_nsg" {
  name                = "acceptanceTestSecurityGroup1"
  location            = "eastus"
  resource_group_name = "terraform"
}

resource "azurerm_network_security_rule" "rule1" {

  for_each = {
    22  = "10.0.0.0/8"
    443 = "192.168.0.0/16"
  }


  name                        = "sec_rule_${each.key}"
  priority                    = 100 + each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.key
  source_address_prefix       = each.value
  destination_address_prefix  = "*"
  resource_group_name         = "terraform"
  network_security_group_name = azurerm_network_security_group.terra_nsg.name
}


resource "azurerm_network_interface_security_group_association" "name" {
  for_each = toset(["finance", "logistics", "marketing"])

  network_interface_id      = azurerm_network_interface.example[each.value].id
  network_security_group_id = azurerm_network_security_group.terra_nsg.id
}