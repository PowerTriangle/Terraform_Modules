resource "azurerm_key_vault_key" "key_vault_key" {
  # checkov:skip=CKV_AZURE_40:Key encryption expiration requested to be disabled as no rotation policy exists
  for_each     = var.enable_encryption_at_host ? var.disk_encryption_set : {}
  name         = "${each.key}-key"
  key_vault_id = azurerm_key_vault.key_vault.id
  key_type     = "RSA-HSM"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  depends_on = [azurerm_key_vault_access_policy.pipeline_spn]
}

resource "azurerm_disk_encryption_set" "des" {
  for_each                  = var.enable_encryption_at_host ? var.disk_encryption_set : {}
  name                      = each.key
  location                  = var.location
  resource_group_name       = each.value["resource_group_name"] == null ? var.resource_group_name : each.value["resource_group_name"]
  key_vault_key_id          = azurerm_key_vault_key.key_vault_key[each.key].versionless_id
  auto_key_rotation_enabled = true
  tags                      = var.tags_override

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "des-id" {
  for_each     = var.enable_encryption_at_host ? var.disk_encryption_set : {}
  key_vault_id = azurerm_key_vault.key_vault.id

  tenant_id = azurerm_disk_encryption_set.des[each.key].identity[0].tenant_id
  object_id = azurerm_disk_encryption_set.des[each.key].identity[0].principal_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign",
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}

resource "azurerm_role_assignment" "des-id" {
  for_each             = var.enable_encryption_at_host ? var.disk_encryption_set : {}
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.des[each.key].identity[0].principal_id
}
