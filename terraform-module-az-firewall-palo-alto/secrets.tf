resource "azurerm_key_vault_secret" "password" {
  // checkov:skip=CKV_AZURE_41:Secret encryption expiration requested to be disabled as no rotation policy exists
  count        = var.use_existing_secrets ? 0 : 1
  content_type = "text/plain"
  key_vault_id = var.key_vault_id
  name         = "eituksalzt2fw-password"
  value        = var.vm_password == null ? random_password.password.result : var.vm_password
}

resource "azurerm_key_vault_secret" "username" {
  // checkov:skip=CKV_AZURE_41:Secret encryption expiration requested to be disabled as no rotation policy exists
  count        = var.use_existing_secrets ? 0 : 1
  content_type = "text/plain"
  key_vault_id = var.key_vault_id
  name         = "eituksalzt2fw-username"
  value        = var.vm_username == null ? "eituksalzt2fw-user" : var.vm_username
}

resource "random_password" "password" {
  length           = 24
  min_lower        = 4
  min_numeric      = 4
  min_special      = 4
  min_upper        = 4
  override_special = "!$%&()-_=+[]{}<>:?"
}