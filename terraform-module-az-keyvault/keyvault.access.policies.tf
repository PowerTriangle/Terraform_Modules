// ADE backup access policy
resource "azurerm_key_vault_access_policy" "azure_backup_access_policy" {
  count = (var.enabled_for_disk_encryption) && (!var.enable_rbac_authorization) ? 1 : 0

  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.azure_backup_spn[count.index].object_id

  certificate_permissions = []
  key_permissions         = ["Get", "List", "Backup"]
  secret_permissions      = ["Get", "List", "Backup"]
  storage_permissions     = []
}

// Encryption at host access policy
resource "azurerm_key_vault_access_policy" "encryption_at_host_access_policy" {
  // Please do not change this functionality, it is a combination of the standard access policy and the encryption at host permissions with the ability to perform key rotation.
  // Object IDs should not be used within the code as its not user friendly, use UPN or SPN instead.
  // If pipeline SPN doesn't have read only access to read the object IDs then please raise it with M365 team.
  // Such access to SPNs has been preapproved by the EIS team. All the ALZ pipeline SPNs already have such access.
  // If you are using an SPN that does not have such access, chances are you are using a new SPN or legacy Avanade SPN.
  for_each = toset(concat(
    data.azuread_users.users_upns_encryption_at_host_access.object_ids,
    data.azuread_service_principals.spns_encryption_at_host_access.object_ids,
    data.azuread_groups.groups_encryption_at_host_access.object_ids,
    local.keyvault_encryption_at_host_access_policy_object_ids,
  ))

  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.key

  //Encryption at host requires "WrapKey", "UnwrapKey" and enabling key rotation requires "Rotate", "SetRotationPolicy" in addition to general purpose key permissions in the policy above.
  key_permissions         = ["Get", "List", "Update", "Create", "Delete", "GetRotationPolicy", "Recover", "WrapKey", "UnwrapKey", "Rotate", "SetRotationPolicy"]
  secret_permissions      = ["Get", "List", "Set", "Delete", "Recover"]
  storage_permissions     = ["Get"]
  certificate_permissions = ["Get", "List", "Update", "Create", "Delete", "Recover", "Import"]
}

// Pipeline SPN access policy
resource "azurerm_key_vault_access_policy" "pipeline_spn" {
  count = (!var.disable_default_access_policies) && (!var.enable_rbac_authorization) ? 1 : 0

  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
  key_permissions         = var.enabled_for_disk_encryption || var.enable_encryption_at_host ? ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"] : ["Get", "List", "Backup", "Create", "Rotate", "GetRotationPolicy", "SetRotationPolicy", "Delete", "Update", "Purge", "Recover"]
  secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  storage_permissions     = []
}

// Standard access policy
resource "azurerm_key_vault_access_policy" "standard_access_policy" {
  // Please do not change this functionality. Object IDs should not be used within the code as its not user friendly, use UPN or SPN instead.
  // If pipeline SPN doesn't have read only access to read the object IDs then please raise it with M365 team.
  // Such access to SPNs has been preapproved by the EIS team. All the ALZ pipeline SPNs already have such access.
  // If you are using an SPN that does not have such access, chances are you are using a new SPN or legacy Avanade SPN.
  for_each = toset(concat(
    data.azuread_users.users_upns_standard_access.object_ids,
    data.azuread_service_principals.spns_standard_access.object_ids,
    data.azuread_groups.groups_standard_access.object_ids,
    local.keyvault_standard_access_policy_object_ids,
  ))

  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.key

  certificate_permissions = ["Get", "List", "Update", "Create", "Delete", "Recover", "Import"]
  key_permissions         = ["Get", "List", "Update", "Create", "Delete", "GetRotationPolicy", "Recover"]
  secret_permissions      = ["Get", "List", "Set", "Delete", "Recover"]
  storage_permissions     = ["Get"]
}
