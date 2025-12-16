resource "azurerm_key_vault_secret" "password" {
  // checkov:skip=CKV_AZURE_41:Secret encryption expiration requested to be disabled as no rotation policy exists
  count        = var.secrets_already_exist == false ? 1 : 0
  content_type = "text/plain"
  key_vault_id = var.subscription_env_config["keyvault_id"]
  name         = "${var.vm_name}-password"
  value        = var.vm_password == null ? random_password.password[0].result : var.vm_password
}

resource "azurerm_key_vault_secret" "username" {
  // checkov:skip=CKV_AZURE_41:Secret encryption expiration requested to be disabled as no rotation policy exists
  count        = var.secrets_already_exist == false ? 1 : 0
  content_type = "text/plain"
  key_vault_id = var.subscription_env_config["keyvault_id"]
  name         = "${var.vm_name}-username"
  value        = var.vm_username == null ? "${var.vm_name}-user" : var.vm_username
}

resource "random_password" "password" {

  count            = var.vm_password == null && var.secrets_already_exist == false ? 1 : 0
  length           = 24
  min_lower        = 4
  min_numeric      = 4
  min_special      = 4
  min_upper        = 4
  override_special = "!$%&()-_=+[]{}<>:?"
}