output "keyvault" {
  description = "keyvault"
  value       = azurerm_key_vault.key_vault
}

output "des_ids" {
  value = { for des_name, des_info in azurerm_disk_encryption_set.des : des_name => des_info.id }
}

output "des_principal_ids" {
  value = flatten([for des, des_info in azurerm_disk_encryption_set.des : [for identity in des_info.identity : identity.principal_id]])
}
