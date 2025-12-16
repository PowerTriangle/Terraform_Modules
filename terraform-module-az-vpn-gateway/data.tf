data "azurerm_key_vault_secret" "shared_key" {
  for_each     = var.vpn_connections
  key_vault_id = var.key_vault_id
  name         = each.value.shared_key_secret_name
}
