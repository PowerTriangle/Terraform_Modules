output "backup_vault_id" {
  description = "id value for azure backup vault"
  value       = azurerm_data_protection_backup_vault.backup_vault.id
}

output "backup_vault_identity" {
  description = "identity for azure backup vault"
  value       = azurerm_data_protection_backup_vault.backup_vault.identity
}

output "backup_policy_disk_id" {
  description = "The ID of disk backup policies"
  value = values(azurerm_data_protection_backup_policy_disk.backup_policy)[*].id
}

output "backup_policy_blob_storage_id" {
  description = "The ID of blob storage backup policies"
  value = values(azurerm_data_protection_backup_policy_blob_storage.backup_policy)[*].id
}

output "backup_policy_kubernetes_id" {
  description = "The ID of Kubernetes backup policies"
  value       = values(azurerm_data_protection_backup_policy_kubernetes_cluster.backup_policy)[*].id
}

#mysql_flexible server backup is still in preview mode therefore commenting out until it has been released
# output "backup_policy_mysql_flexible_id" {
#   description = "The ID of mysql flexible server backup policies"
#   value       =  values(azurerm_data_protection_backup_policy_mysql_flexible_server.backup_policy)[*].id
# }

output "backup_policy_postgresql_id" {
  description = "The ID of postgresql backup policies"
  value = values(azurerm_data_protection_backup_policy_postgresql.backup_policy)[*].id
}

output "backup_policy_postgresql_flexible_id" {
  description = "The ID of postgresql flexible server backup policies"
  value       = values(azurerm_data_protection_backup_policy_postgresql_flexible_server.backup_policy)[*].id
}

output "backup_vault_instance_disk_id" {
  description = "The ID of disk backup instances"
  value       = values(azurerm_data_protection_backup_instance_disk.backup_instance)[*].id
  
}

output "backup_vault_instance_blob_storage_id" {
  description = "The ID of blob storage backup instances"
  value       = values(azurerm_data_protection_backup_instance_blob_storage.backup_instance)[*].id
}

output "backup_vault_instance_kubernetes_id" {
  description = "The ID of kubernetes backup instances"
  value       = values(azurerm_data_protection_backup_instance_kubernetes_cluster.backup_instance)[*].id
}

output "backup_vault_instance_postgresql_id" {
  description = "The ID of postgresql backup instances"
  value       = values(azurerm_data_protection_backup_instance_postgresql.backup_instance)[*].id
}

output "backup_vault_instance_postgresql_flexible_id" {
  description = "The ID of postgresql flexible server backup instances"
  value       = values(azurerm_data_protection_backup_instance_postgresql_flexible_server.backup_instance)[*].id
}

# output "backup_vault_instance_mysql_flexible_id" {
#   description = "The ID of mysql flexible server backup instances"
#   value       = values(azurerm_data_protection_backup_instance_mysql_flexible_server.backup_instance)[*].id
# }
