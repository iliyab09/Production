variable "ResourceGroup_location" {
  default = "West Europe"
}

variable "ResourceGroup_name" {
  default = "Production"
}

variable "VirtualNetwork_name" {
  default = "VirtualNetwork"
}

variable "SubNet_VM" {
  default = "SubNet_VM"
}

variable "NetworkSecurityGroup_VM" {
  default = "NSG_VM"
}

variable "NetworkSecurityGroup_SQL" {
  default = "NSG_SQL"
}

variable "name_count" {
  default = ["server1", "server2"]
}

variable "pass" {
  default = "987654Qweasd!"
  description = "VMPass"
}

variable "userName" {
  default = "iliyab09"
  description = "VMUsername"
}

variable "DBuserName" {
  default = "iliyab09"
  description = "DBuserName"
}

variable "DBpass" {
  default = "H@Sh1CoR3!"
  description = "DBpass"
}