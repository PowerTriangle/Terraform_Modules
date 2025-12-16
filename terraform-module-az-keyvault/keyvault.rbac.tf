// Allow Azure Backup to correctly back up VMs that are encrypted using Azure Disk Encryption (ADE)
// https://learn.microsoft.com/en-us/azure/backup/backup-azure-vms-encryption#provide-permissions
// This role should probably be moved to the management group level.
resource "azurerm_role_definition" "key_vault_backup_operator" {
  count = var.enabled_for_disk_encryption && var.enable_rbac_authorization ? 1 : 0
  name  = "${local.keyvault_name} Backup Operator"
  scope = azurerm_key_vault.key_vault.id
  permissions {
    data_actions = [
      "Microsoft.KeyVault/vaults/keys/backup/action",
      "Microsoft.KeyVault/vaults/secrets/backup/action",
      "Microsoft.KeyVault/vaults/secrets/getSecret/action",
      "Microsoft.KeyVault/vaults/keys/read",
      "Microsoft.KeyVault/vaults/secrets/readMetadata/action"
    ]
  }
}

resource "azurerm_role_assignment" "azure_backup_access" {
  count              = var.enabled_for_disk_encryption && var.enable_rbac_authorization ? 1 : 0
  scope              = azurerm_key_vault.key_vault.id
  principal_id       = data.azuread_service_principal.azure_backup_spn[count.index].object_id
  role_definition_id = azurerm_role_definition.key_vault_backup_operator[count.index].role_definition_resource_id
}


// Grant the SPN the pipeline runs under the Key Vault Administrator role
resource "azurerm_role_assignment" "pipeline_spn_access" {
  count                = (!var.disable_default_access_policies) && var.enable_rbac_authorization ? 1 : 0
  scope                = azurerm_key_vault.key_vault.id
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Administrator"
}

// User, Group and SPN role assignments to the key vault
resource "azurerm_role_assignment" "key_vault_access" {
  for_each             = merge(local.spn_role_definitions, local.user_role_definitions, local.group_role_definitions)
  scope                = azurerm_key_vault.key_vault.id
  principal_id         = each.value.principal_id
  role_definition_name = each.value.role_definition_name
}
