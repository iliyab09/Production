variable "VM_Name" {
  type        = string
  description = "The Name VM"
}

variable "ResourceGroup_name" {
  type        = string
  description = "The Reasourse Group"
}

variable "ResourceGroup_location" {
  type        = string
  description = "Reasourse Group Location"
}

variable "Size" {
  type        = string
  default = "Standard_B2ms"
  description = "VM Size"
}

variable "userName" {
  type        = string
  description = "username"
}

variable "pass" {
  type        = string
  description = "password"
}

variable "availabilitySetId"{
  type        = string
  description = "availabilitySetId"
}

variable "subNet"{
  type        = string
  description = "availabilitySetId"
}

# variable "publick_ip_address_id"{
#   type        = string
#   description = "publick_ip_address_id"
# }
