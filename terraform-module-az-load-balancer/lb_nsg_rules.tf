# Optional NSG rules. Each corresponds to one azurerm_lb_rule.
resource "azurerm_network_security_rule" "allow_inbound_ips" {
  for_each = {
    for k, v in local.in_rules : k => v
    if var.network_security_group_name != null && var.network_security_group_name != "" && length(var.network_security_allow_source_ips) > 0
  }

  name                        = "allow-inbound-ips-${each.key}"
  network_security_group_name = var.network_security_group_name
  resource_group_name         = coalesce(var.network_security_resource_group_name, var.resource_group_name)
  description                 = "Auto-generated for load balancer ${var.name} port ${each.value.rule.protocol}/${try(each.value.rule.backend_port, each.value.rule.port)}: allowed inbound IP ranges"

  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = title(replace(lower(each.value.rule.protocol), "all", "*"))
  source_port_range          = "*"
  destination_port_ranges    = [each.value.rule.port == "0" ? "*" : try(each.value.rule.backend_port, each.value.rule.port)]
  source_address_prefixes    = var.network_security_allow_source_ips
  destination_address_prefix = local.frontend_addresses[each.value.fipkey]

  # For the priority, we add this %10 so that the numbering would be a bit more sparse instead of sequential.
  # This helps tremendously when a mass of indexes shifts by +1 or -1 and prevents problems when we need to shift rules reusing already used priority index.
  priority = try(
    each.value.rule.nsg_priority,
    index(keys(local.in_rules), each.key) * 10 + parseint(local.rules_hash[each.key], 16) % 10 + var.network_security_base_priority
  )
}
