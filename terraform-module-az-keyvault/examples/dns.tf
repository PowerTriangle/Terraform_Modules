resource "azurerm_private_dns_zone" "pep" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = module.key_vault_resource_group.resource_group_name
}
