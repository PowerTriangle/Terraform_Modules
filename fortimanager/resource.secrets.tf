resource "azurerm_key_vault_secret" "password" {
  content_type = "text/plain"
  key_vault_id = var.subscription_env_config["keyvault_id"]
  name         = "${var.vm_name}-password"
  value        = var.vm_password == null ? random_password.password.result : var.vm_password
}

resource "azurerm_key_vault_secret" "username" {
  content_type = "text/plain"
  key_vault_id = var.subscription_env_config["keyvault_id"]
  name         = "${var.vm_name}-username"
  value        = var.vm_username == null ? "${var.vm_name}-user" : var.vm_username
}

resource "random_password" "password" {
  length           = 24
  min_lower        = 4
  min_numeric      = 4
  min_special      = 4
  min_upper        = 4
  override_special = "!$%&()-_=+[]{}<>:?"
}
