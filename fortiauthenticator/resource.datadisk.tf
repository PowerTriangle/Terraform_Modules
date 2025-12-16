resource "azurerm_managed_disk" "disks_data" {
  // checkov:skip=CKV_AZURE_93:Azure Disk Encryption is not supported due to use of custom marketplace image.
  // checkov:skip=CKV_AZURE_251:The FortiAnalyzer VM will not be publicly accessible therefore not needed.
  for_each                   = var.data_disks
  create_option              = each.value.source == "new" ? "Empty" : "Copy"
  disk_size_gb               = each.value.size
  hyper_v_generation         = var.vm_hyper_v_generation == null ? null : var.vm_hyper_v_generation
  location                   = var.resource_group_location
  name                       = each.value.name
  on_demand_bursting_enabled = false
  os_type                    = "Linux"
  resource_group_name        = var.resource_group_name
  source_resource_id         = each.value.source != "new" ? each.value.source : null
  storage_account_type       = each.value.class
  disk_encryption_set_id     = var.enable_encryption_at_host == true ? var.disk_encryption_set_id : null
  tags                       = var.tags
  zone                       = contains(["standardssd_zrs", "premium_zrs"], lower(each.value.class)) ? null : var.availability_zone
  lifecycle {
    ignore_changes = [
      encryption_settings,
      hyper_v_generation,
      source_resource_id,
      create_option,
      zone
    ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "disks_data_attach" {
  for_each           = var.data_disks
  caching            = lookup(each.value, "caching", "ReadWrite")
  lun                = each.key
  managed_disk_id    = azurerm_managed_disk.disks_data[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
}