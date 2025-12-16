output "nat_rule_id" {
  description = "The ID of virtual network gateway nat rules"
  value       = { for k, v in azurerm_virtual_network_gateway_nat_rule.nat_rules : k => v.id }
}
