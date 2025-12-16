variable "resource_group_name" {
  type = string
}

variable "keyvault_name" {
  type = string
}

variable "private_endpoint_name" {
  type = string
}

data "azurerm_key_vault" "example" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_private_endpoint_connection" "example" {
  name                = var.private_endpoint_name
  resource_group_name = var.resource_group_name
}
