variable "prefix" {
  default = "Muthu"
  description = "The Prefix used for all resources in this example"
}

variable "location" {
  default = "Central US"
  description = "The Azure Region in which the resources in this example should exist"
}


output "instance_ip_addr" {
  value = "${azurerm_public_ip.example.ip_address}"
}