output "resource_group_name" {
  description = "Resource Group Name"
  value       = module.key_vault_resource_group.resource_group_name
}

output "keyvault" {
  description = "The Key Vault"
  value       = module.key_vault.keyvault
}

output "keyvault_pep_name" {
  description = "The Private Endpoint Name"
  value       = "${module.key_vault.keyvault.name}-pep"
}

output "pep_subnet_id" {
  description = "The private endpoint subnet ID"
  value       = module.vnet.subnet_ids["pep"]
}

output "des_id" {
  value = module.key_vault.des_ids
}
