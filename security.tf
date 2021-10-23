resource "azurerm_network_security_group" "NSG_VM" {
  name                = var.NetworkSecurityGroup_VM
  location            = var.ResourceGroup_location
  resource_group_name = var.ResourceGroup_name
}

resource "azurerm_network_security_rule" "NSG_VM" {
  name                        = "port_8080"
  priority                    = 100
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 8080
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.ResourceGroup_name
  network_security_group_name = azurerm_network_security_group.NSG_VM.name
}



resource "azurerm_network_security_rule" "NSG_VM1" {
  name                        = "port_22"
  priority                    = 200
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.ResourceGroup_name
  network_security_group_name = azurerm_network_security_group.NSG_VM.name
}


resource "azurerm_network_security_rule" "NSG_VM2" {
  name                        = "port_5432"
  priority                    = 300
  direction                   = "inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 5432
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.ResourceGroup_name
  network_security_group_name = azurerm_network_security_group.NSG_VM.name
}



# resource "azurerm_network_security_group" "NSG_SQL" {
#   name                = var.NetworkSecurityGroup_SQL
#   location            = var.ResourceGroup_location
#   resource_group_name = var.ResourceGroup_name
# }

# resource "azurerm_network_security_rule" "NSG_SQL" {
#   name                        = "port_5432"
#   priority                    = 100
#   direction                   = "inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = 5432
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = var.ResourceGroup_name
#   network_security_group_name = azurerm_network_security_group.NSG_SQL.name 
# }