resource "azurerm_key_vault" "key_vault" {
  name                            = local.keyvault_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  sku_name                        = local.sku_name
  public_network_access_enabled   = var.public_network_access_enabled
  enable_rbac_authorization       = var.enable_rbac_authorization
  tags                            = var.tags_override

  // If we are using RBAC authorisation then clear access policies
  access_policy = var.enable_rbac_authorization ? [] : null

  dynamic "network_acls" {
    for_each = (length(var.acl_ip_rules) > 0 || length(var.virtual_network_subnet_ids) > 0) ? [""] : []
    content {
      default_action             = var.acl_default_action
      bypass                     = "AzureServices"
      ip_rules                   = var.acl_ip_rules
      virtual_network_subnet_ids = var.virtual_network_subnet_ids
    }
  }
}

resource "azurerm_private_endpoint" "pe" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = coalesce(var.private_endpoint_name, "${azurerm_key_vault.key_vault.name}-pep")
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = coalesce(var.private_service_connection_name, "${azurerm_key_vault.key_vault.name}-connection")
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.key_vault.id
    subresource_names              = ["vault"]
  }

  tags = merge(var.tags_override, tomap(
    { "Service" = "KV private endpoint" }
  ))

  private_dns_zone_group {
    name                 = "privatelink.vaultcore.azure.net"
    private_dns_zone_ids = ["${var.pep_private_dns_rg_id}/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"]
  }
}
