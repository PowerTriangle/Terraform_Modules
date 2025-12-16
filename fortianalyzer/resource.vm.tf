resource "azurerm_linux_virtual_machine" "main" {
  // checkov:skip=CKV_AZURE_1:Custom Marketplace image does not support inital SSH authentication.
  // checkov:skip=CKV_AZURE_178:Custom Marketplace image does not support inital SSH authentication.
  // checkov:skip=CKV_AZURE_149:Custom Marketplace image only supports password authentication therefore password authentication needs to be enabled.
  // checkov:skip=CKV_AZURE_50:Custom Marketplace image doesn't support Virtual Machine Extensions.
  location                        = var.resource_group_location
  name                            = var.vm_name
  network_interface_ids           = values(azurerm_network_interface.nics)[*].id
  resource_group_name             = var.resource_group_name
  tags                            = merge(var.tags, var.vm_setting_tags)
  size                            = var.vm_size
  zone                            = var.availability_zone # var.availability_zone == null ? [] : var.availability_zone
  admin_username                  = azurerm_key_vault_secret.username.value
  admin_password                  = azurerm_key_vault_secret.password.value
  allow_extension_operations      = var.allow_extension_operations #FortiAnalyzer Custom Marketplace Image does not support extensions therefore disabling them.
  disable_password_authentication = false                          #var.disable_passwd_auth
  #Note: When an admin_password is specified disable_password_authentication must be set to false. ~> NOTE: One of either admin_password or admin_ssh_key must be specified.
  encryption_at_host_enabled = var.enable_encryption_at_host
  secure_boot_enabled        = false #secure boot is not supported with custom images.
  custom_data                = var.vm_custom_data
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
    name                      = var.vm_osdisk_name == null ? "${var.vm_name}-osdisk" : var.vm_osdisk_name
    caching                   = "ReadWrite"
    storage_account_type      = var.storage_account_type
    disk_size_gb              = var.vm_osdisk_size_gb
    disk_encryption_set_id    = var.enable_encryption_at_host == true ? var.disk_encryption_set_id : null
    write_accelerator_enabled = false #write accelerator cannot be enabled if caching type is read write
    dynamic "diff_disk_settings" {
      for_each = var.ephemeral_os_disk == true ? [""] : []
      content {
        option = "Local"
      }
    }
  }
  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }
  plan {
    name      = var.image.sku
    publisher = var.image.publisher
    product   = var.image.offer
  }
  lifecycle {
    ignore_changes = [
      zone
    ]
  }
}

resource "azurerm_marketplace_agreement" "fortinet" {
  count     = var.image.enable_marketplace_plan ? 1 : 0
  publisher = var.image.publisher
  offer     = var.image.offer
  plan      = var.image.sku
}