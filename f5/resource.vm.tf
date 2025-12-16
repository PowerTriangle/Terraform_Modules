resource "azurerm_linux_virtual_machine" "main" {
  // checkov:skip=CKV_AZURE_1:Fortigate Custom Marketplace image does not support inital SSH authentication.
  // checkov:skip=CKV_AZURE_178:Fortigate Custom Marketplace image does not support inital SSH authentication.
  // checkov:skip=CKV_AZURE_149:Fortigate Custom Marketplace image only supports password authentication therefore password authentication needs to be enabled.
  location                         = var.resource_group_location
  name                             = var.vm_name
  network_interface_ids            = values(azurerm_network_interface.nics)[*].id
  resource_group_name              = var.resource_group_name
  tags                             = merge(var.tags, var.vm_setting_tags)
  size                             = var.vm_size
  zone                             = var.availability_zone
  admin_username                   = azurerm_key_vault_secret.username.value
  admin_password                   = azurerm_key_vault_secret.password.value
  allow_extension_operations       = false #F5 Big-IP Custom Marketplace Image does not support extensions therefore disabling them.
  disable_password_authentication  = false #Note: When an admin_password is specified disable_password_authentication must be set to false. ~> NOTE: One of either admin_password or admin_ssh_key must be specified.
  encryption_at_host_enabled       = var.enable_encryption_at_host #default prod now: false, but available to be encrypted
  secure_boot_enabled              = false #secure boot is not supported with f5 Big-IP images.
  custom_data                      = base64encode(var.f5vm_custom_script)
  boot_diagnostics {
    storage_account_uri = var.subscription_env_config["boot_diagnostics_storage_uri"]
  }
  dynamic "identity" {
    for_each = var.identity_type != null ? [""] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : []
    }
  }
  os_disk {
    name              = "${var.vm_name}-osdisk"
    caching           = "ReadWrite"
    storage_account_type = var.storage_account_type
    disk_size_gb      = var.vm_osdisk_size_gb
    write_accelerator_enabled = false #write accelerator cannot be enabled if caching type is read write
      dynamic "diff_disk_settings" {
        for_each = var.ephemeral_os_disk == true ? [""] : []
        content {
          option = "Local"
        }
      }
    }
 source_image_reference {
    publisher = "f5-networks"
    offer     = var.f5_offer[var.license_type]
    sku       = var.f5_sku[var.license_type]
    version   = var.f5_version
  }
  plan {
    name      = var.f5_sku[var.license_type]
    publisher = "f5-networks"
    product   = var.f5_offer[var.license_type]
  }
  lifecycle {
    ignore_changes = [
      zone
    ]
  }
}

resource "azurerm_marketplace_agreement" "f5networks" {
  count     = var.accept_marketplace_agreement ? 1 : 0
  publisher = "f5-networks"
  offer     = var.f5_offer[var.license_type]
  plan      = var.f5_sku[var.license_type]
}