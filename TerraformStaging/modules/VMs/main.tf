
resource "azurerm_linux_virtual_machine" "AppVM" {
  name                            = var.VM_Name
  resource_group_name             = var.ResourceGroup_name
  location                        = var.ResourceGroup_location
  size                            = var.Size
  admin_username                  = var.userName
  admin_password                  = var.pass
  disable_password_authentication = false
  availability_set_id             = var.availabilitySetId
  network_interface_ids           = [azurerm_network_interface.NIC_VM.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


#NICVM! Network interface for WEBVM
resource "azurerm_network_interface" "NIC_VM" {
  name                = "${var.VM_Name}-NIC"
  location            = var.ResourceGroup_location
  resource_group_name = var.ResourceGroup_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subNet
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = var.publick_ip_address_id
  }
}
