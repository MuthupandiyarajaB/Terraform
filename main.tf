resource "azurerm_virtual_machine" "example" {
  name                  = "${local.virtual_machine_name}"
  location              = "${azurerm_resource_group.example.location}"
  resource_group_name   = "${azurerm_resource_group.example.name}"
  network_interface_ids = ["${azurerm_network_interface.example.id}"]
  vm_size               = "Standard_DS1_v2"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.virtual_machine_name}"
    admin_username = "${local.admin_username}"
    admin_password = "${local.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

    provisioner "local-exec" {
      command = "./provision/environment/dev/scripts/dynamicinventory.sh"
    }
    provisioner "local-exec" {
      command = "@echo ##vso[task.setvariable variable=ip]${azurerm_public_ip.example.ip_address}"
    }

    provisioner "local-exec" {
    command = "sleep 180;sed -i 's/{host}/${azurerm_public_ip.example.ip_address}/g' ./provision/environment/dev/inventory/inventory"
    }

    provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ./provision/environment/dev/playbooks/webservers.yml -i ./provision/environment/dev/inventory/inventory"
    }

}