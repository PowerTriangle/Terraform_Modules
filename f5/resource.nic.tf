resource "azurerm_network_interface" "nics" {
  for_each                       = var.nics
  location                       = var.resource_group_location
  name                           = each.value.name
  resource_group_name            = var.resource_group_name
  ip_forwarding_enabled = each.value.enable_ip_forwarding == null ? null : each.value.enable_ip_forwarding
  accelerated_networking_enabled = each.value.enable_accelerated_networking == null ? null : each.value.enable_accelerated_networking
  tags                           = var.tags

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations
    content {
      name                          = "${var.vm_name}-${ip_configuration.key}"
      primary                       = true
      subnet_id                     = ip_configuration.value.subnet_id
      private_ip_address_allocation = ip_configuration.value.private_ip_address == null ? "Dynamic" : "Static"
      private_ip_address            = ip_configuration.value.private_ip_address == null ? null : ip_configuration.value.private_ip_address
    }
  }
}