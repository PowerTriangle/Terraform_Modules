resource "random_password" "shared_key" {
  length = 12
}

resource "azurerm_key_vault_secret" "shared_key" {
  name            = "dummy-vpn-shared-key"
  content_type    = "vpn-pre-shared-key"
  expiration_date = "2024-06-01T11:00:00Z"
  value           = random_password.shared_key.result
  key_vault_id    = module.key_vault.keyvault.id
}

module "vpn_gateway" {
  source              = "../."
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  key_vault_id        = module.key_vault.keyvault.id
  gateway_pip_name    = "test-gw-pip"
  gateway_name        = "test-gw"
  gateway_sku         = "Basic"
  gateway_subnet_id   = module.vnet.subnet_ids["GatewaySubnet"]
  vpn_connections = {
    onprem = {
      dh_group                   = "DHGroup14"
      dpd_timeout_seconds        = 45
      ike_encryption             = "AES256"
      ike_integrity              = "SHA256"
      ipsec_encryption           = "AES256"
      ipsec_integrity            = "SHA256"
      local_network_gateway_name = "dummy_network_gw"
      pfs_group                  = "None"
      remote_address_space = [
        "192.168.1.0/24",
        "192.168.2.0/24"
      ]
      remote_gateway_address = "8.8.8.8"
      shared_key_secret_name = "dummy-vpn-shared-key"
    }
  }
}
