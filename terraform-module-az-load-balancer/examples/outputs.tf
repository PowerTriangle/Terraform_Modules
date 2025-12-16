output "resource_group_name" {
  description = "Resource Group Name"
  value       = module.resource_group.resource_group_name
}

output "subnet_ids" {
  description = "The identifiers of the created Subnets."
  value       = module.network.subnet_ids
}

output "network_security_group_ids" {
  description = "The identifiers of the created Network Security Groups."
  value       = module.network.network_security_group_ids
}

output "internal_http_lb_name" {
  description = "The name of the internal load balancer."
  value       = module.internal_http_load_balancer.load_balancer_name
}

output "public_sftp_lb_name" {
  description = "The name of the public load balancer."
  value       = module.public_sftp_load_balancer.load_balancer_name
}

output "internal_http_lb_fe_ips" {
  description = "The frontend IP addresses of the internal load balancer."
  value       = module.internal_http_load_balancer.frontend_ip_configs
}

output "public_sftp_lb_fe_ips" {
  description = "The frontend IP addresses of the public load balancer."
  value       = module.public_sftp_load_balancer.frontend_ip_configs
}

output "internal_http_lb_fe_rules" {
  description = "The frontend rules of the internal load balancer."
  value       = module.internal_http_load_balancer.frontend_combined_rules
}

output "public_sftp_lb_fe_rules" {
  description = "The frontend rules of the public load balancer."
  value       = module.public_sftp_load_balancer.frontend_combined_rules
}
