module "key_vault" {
  source                     = "../"
  resource_group_name        = module.key_vault_resource_group.resource_group_name
  keyvault_name              = "${var.env}-kv-${var.suffix}"
  soft_delete_retention_days = 7
  #enabled_for_disk_encryption = true
  enable_private_endpoint    = azurerm_private_dns_zone.pep != null # Setting implicit dependency
  private_endpoint_subnet_id = module.vnet.subnet_ids["pep"]
  pep_private_dns_rg_id      = module.key_vault_resource_group.resource_group_id
  enable_encryption_at_host  = true
  disk_encryption_set = {
    des-01 = {}
    des-02 = {
      resource_group_name = module.des_resource_group_02.resource_group_name
    }
  }
}
