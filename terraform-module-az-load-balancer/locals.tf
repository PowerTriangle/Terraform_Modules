locals {
  # Decide how the backend machines access internet. If outbound rules are defined use them instead of the default route.
  # This is an inbound rule setting, applicable to all inbound rules as you cannot mix SNAT with Outbound rules for a single backend.
  disable_outbound_snat = anytrue([for _, v in var.frontend_ips : try(length(v.out_rules) > 0, false)])

  # Calculate inbound rules
  in_flat_rules = flatten([
    for fipkey, fip in var.frontend_ips : [
      for rulekey, rule in try(fip.in_rules, {}) : {
        fipkey  = fipkey
        fip     = fip
        rulekey = rulekey
        rule    = rule
      }
    ]
  ])
  in_rules = { for v in local.in_flat_rules : "${v.fipkey}-${v.rulekey}" => v }

  # Calculate outbound rules
  out_flat_rules = flatten([
    for fipkey, fip in var.frontend_ips : [
      for rulekey, rule in try(fip.out_rules, {}) : {
        fipkey  = fipkey
        fip     = fip
        rulekey = rulekey
        rule    = rule
      }
    ]
  ])
  out_rules = { for v in local.out_flat_rules : "${v.fipkey}-${v.rulekey}" => v }

  # Map of all frontend IP addresses, public or private.
  frontend_addresses = {
    for v in azurerm_lb.lb.frontend_ip_configuration : v.name => try(data.azurerm_public_ip.this[v.name].ip_address, azurerm_public_ip.this[v.name].ip_address, v.private_ip_address)
  }

  # A map of hashes calculated for each inbound rule. Used to calculate NSG inbound rules priority index if modules is also used to automatically manage NSG rules.
  rules_hash = {
    for k, v in local.in_rules : k => substr(
      sha256("${local.frontend_addresses[v.fipkey]}:${v.rule.port}"),
      0,
      4
    )
    if var.network_security_group_name != null && var.network_security_group_name != "" && length(var.network_security_allow_source_ips) > 0
  }

  # This output is required for the module tests to ensure the correct correct frontend rules
  # are given the correct IP addresses.
  output_rules = {
    for i, k in keys(local.in_rules) : k => {
      rulekey     = local.in_rules[k].rulekey
      frontend_ip = local.frontend_addresses[local.in_rules[k].fipkey]
    }
  }
}
