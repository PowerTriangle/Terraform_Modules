resource "azurerm_public_ip" "this" {
  for_each = { for k, v in var.frontend_ips : k => v if try(v.create_public_ip, false) }

  name                = coalesce(try(each.value.public_ip_name, null), "${var.name}-${each.key}-pip")
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.enable_zones ? var.avzones : null
  tags                = var.tags
}

data "azurerm_public_ip" "this" {
  for_each = {
    for k, v in var.frontend_ips : k => v
    if try(v.public_ip_name, null) != null && !try(v.create_public_ip, false)
  }

  name                = try(each.value.public_ip_name, "")
  resource_group_name = try(each.value.public_ip_resource_group, var.resource_group_name, "")
}
