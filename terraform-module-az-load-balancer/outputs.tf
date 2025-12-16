output "backend_pool_id" {
  description = "The identifier of the backend pool."
  value       = azurerm_lb_backend_address_pool.lb_backend.id
}

output "frontend_ip_configs" {
  description = "Map of IP addresses, one per each entry of `frontend_ips` input. Contains public IP address for the frontends that have it, private IP address otherwise."
  # value       = local.output_ips
  value = local.frontend_addresses
}

output "health_probe" {
  description = "The health probe object."
  value       = azurerm_lb_probe.probe
}

output "load_balancer_name" {
  description = "The name of the load balancer."
  value       = azurerm_lb.lb.name
}

output "frontend_combined_rules" {
  description = "Map of all inbound rules used by the load balancer."
  value       = local.output_rules
}
