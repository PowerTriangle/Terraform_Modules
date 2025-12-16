module "fortianalyzer" {
  source                  = "../"
  resource_group_name     = var.rg_name
  resource_group_location = var.location
  vm_name                 = "eitprdhsfaz01"
  availability_zone       = 1
  image = {
    version                 = "7.2.9"
    publisher               = "fortinet"
    offer                   = "fortinet-fortianalyzer"
    sku                     = "fortinet-fortianalyzer"
    enable_marketplace_plan = true
  }
  enable_encryption_at_host = true
  # enable_secure_boot = true BadRequest: Use of TrustedLaunch setting is not supported for the provided image. Please select Trusted Launch Supported Gen2 OS Image
  vm_osdisk_size_gb      = 81
  disk_encryption_set_id = module.cmk_keyvault["cmk_encryption"].des_ids["cmk-des-02"]
  nics = {
    "00-eitprdhsfaz01" = {
      name                          = "eitprdhsfaz01-nic-01"
      enable_accelerated_networking = true
      enable_ip_forwarding          = true
      ip_configurations = {
        "ipconfig1" = {
          private_ip_address_allocation = "Static"
          private_ip_address            = "192.168.5.249"
          subnet_id                     = module.vnet.vnet_subnets_name_id["vm_subnet"]
        }
      }
    }
  }
  data_disks = {
    "01" = {
      name   = "eitprdhsfaz01-datadisk-01"
      source = "new"
      size   = "500"
      class  = "Premium_ZRS"
    }
  }
  subscription_env_config = {
    boot_diagnostics_storage_uri = azurerm_storage_account.example.primary_blob_endpoint
    keyvault_id                  = azurerm_key_vault.firewall_keyvault.id
    vnet_id                      = module.vnet.vnet_id
  }
  tags = {
    business_unit = "finance"
    environment   = "test"
  }
}