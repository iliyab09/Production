#Provider Credentials
provider "azurerm" {
  features {}
}
#Resource group
resource "azurerm_resource_group" "resours_group" {
  name     = var.ResourceGroup_name
  location = var.ResourceGroup_location
}

#Virtual Network
resource "azurerm_virtual_network" "VN" {
  name                = var.VirtualNetwork_name
  address_space       = ["12.0.0.0/20"]
  location            = var.ResourceGroup_location
  resource_group_name = var.ResourceGroup_name
}

#Sub net VM
resource "azurerm_subnet" "subnetVM" {
  name                 = var.SubNet_VM
  resource_group_name  = var.ResourceGroup_name
  virtual_network_name = azurerm_virtual_network.VN.name
  address_prefixes     = ["12.0.1.0/24"]
}

#Publick ip
resource "azurerm_public_ip" "public_ip" {
  name                = "Publick_IP"
  resource_group_name = var.ResourceGroup_name
  location            = var.ResourceGroup_location
  allocation_method   = "Static"
}



module "VM" {
  count                     = 2
  source                    = "./modules/VMs"
  VM_Name                   = "VMStage${count.index+1}"
  ResourceGroup_name        = var.ResourceGroup_name
  ResourceGroup_location    = var.ResourceGroup_location
  userName                  = var.userName
  pass                      = var.pass
  availabilitySetId         = azurerm_availability_set.availability_set.id
  subNet                    = azurerm_subnet.subnetVM.id
  #publick_ip_address_id     = azurerm_public_ip.public_ip_toVM[count.index].id

}


#Create Postgresql Server
resource "azurerm_postgresql_server" "ps_staging" {
  name                = "ps-db-stage"
  location            = var.ResourceGroup_location
  resource_group_name = var.ResourceGroup_name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = var.DBuserName
  administrator_login_password = var.DBpass
  version                      = "11"
  ssl_enforcement_enabled      = false
}


resource "azurerm_postgresql_firewall_rule" "postgres_firewall" {
  name                = "office"
  resource_group_name = var.ResourceGroup_name
  server_name         = azurerm_postgresql_server.ps_staging.name
  start_ip_address    = data.azurerm_public_ip.ip_data.ip_address#azurerm_public_ip.public_ip.ip_address#data.azurerm_public_ip.ip_data.ip_address
  end_ip_address      = data.azurerm_public_ip.ip_data.ip_address#azurerm_public_ip.public_ip.ip_address#data.azurerm_public_ip.ip_data.ip_address
  
}



data "azurerm_public_ip" "ip_data" {
  name                = azurerm_public_ip.public_ip.name
  resource_group_name = var.ResourceGroup_name
}


# LOAD BALANCER
resource "azurerm_lb" "LoadBalancer" {
  name                = "LoadBalancer"
  location            = var.ResourceGroup_location
  resource_group_name = var.ResourceGroup_name
  
  frontend_ip_configuration {
    name                 = "FronEndPublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}


resource "azurerm_lb_rule" "lb_rule2" {
  resource_group_name = var.ResourceGroup_name
  loadbalancer_id = azurerm_lb.LoadBalancer.id
  name = "lb_rule2"
  protocol = "Tcp"
  frontend_port = 8080
  backend_port = 8080
  frontend_ip_configuration_name = "FronEndPublicIPAddress"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
  }


resource "azurerm_lb_probe" "probe" {
  resource_group_name = var.ResourceGroup_name
  loadbalancer_id     = azurerm_lb.LoadBalancer.id
  name                = "health-probe"
  port                = 8080
}

#BACK END ADDRESS POOL
resource "azurerm_lb_backend_address_pool" "backend_pool"{
  loadbalancer_id = azurerm_lb.LoadBalancer.id
  name = "BackEndPool"
}


# Create the avalibility Set
resource "azurerm_availability_set" "availability_set" {
  name                = "AS"
  location            = var.ResourceGroup_location
  resource_group_name = var.ResourceGroup_name

  tags = {
    environment = "Development"
  }
}

resource "azurerm_lb_nat_rule" "nat_rule_forvm1" {
  resource_group_name            = var.ResourceGroup_name
  loadbalancer_id                = azurerm_lb.LoadBalancer.id
  name                           = "GrantAccess1"
  protocol                       = "Tcp"
  frontend_port                  = 10000
  backend_port                   = 22
  frontend_ip_configuration_name = "FronEndPublicIPAddress"
}

resource "azurerm_lb_nat_rule" "nat_rule_forvm2" {
  resource_group_name            = var.ResourceGroup_name
  loadbalancer_id                = azurerm_lb.LoadBalancer.id
  name                           = "GrantAccess2"
  protocol                       = "Tcp"
  frontend_port                  = 10001
  backend_port                   = 22
  frontend_ip_configuration_name = "FronEndPublicIPAddress"
}


resource "azurerm_network_interface_nat_rule_association" "nat_rule_forvm1" {
  network_interface_id  = module.VM[0].NetworkInterface
  ip_configuration_name = "internal"
  nat_rule_id           = azurerm_lb_nat_rule.nat_rule_forvm1.id
}

resource "azurerm_network_interface_nat_rule_association" "nat_rule_forvm2" {
  network_interface_id  = module.VM[1].NetworkInterface
  ip_configuration_name = "internal"
  nat_rule_id           = azurerm_lb_nat_rule.nat_rule_forvm2.id
}

resource "azurerm_network_interface_backend_address_pool_association" "example" {
  count                     = 2
  network_interface_id      = module.VM[count.index].NetworkInterface
  ip_configuration_name     = "internal"
  backend_address_pool_id   = azurerm_lb_backend_address_pool.backend_pool.id
}


# Subnet allocation to security_group of the VM_Server
resource "azurerm_subnet_network_security_group_association" "subnetVM_assoc" {
  subnet_id                 = azurerm_subnet.subnetVM.id
  network_security_group_id = azurerm_network_security_group.NSG_VM.id
}

# Subnet allocation to security_group of the SQL_Server
# resource "azurerm_subnet_network_security_group_association" "subnetSQL_assoc" {
#   subnet_id                 = azurerm_subnet.subnetSQL.id
#   network_security_group_id = azurerm_network_security_group.NSG_SQL.id
# }


resource "azurerm_network_interface_security_group_association" "NIC1_to_NSG1" {
  count                     = 2
  network_interface_id      = module.VM[count.index].NetworkInterface
  network_security_group_id = azurerm_network_security_group.NSG_VM.id
}

# resource "azurerm_network_interface_security_group_association" "NIC_to_NSG2" {
#   network_interface_id      = azurerm_network_interface.NIC_SQL.id
#   network_security_group_id = azurerm_network_security_group.NSG_SQL.id
# }

#output "out" {
#  value     = azurerm_linux_virtual_machine.AppVM[1].admin_password
#  sensitive = true
#}