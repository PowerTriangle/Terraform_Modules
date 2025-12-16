resource "azurerm_role_assignment" "config_download" {
    count = var.backup_storage_account_id == null ? 0 : 1
    principal_id   = azurerm_linux_virtual_machine.main.identity[0].principal_id
    role_definition_name = "Storage Blob Data Reader"
    scope          = var.backup_storage_account_id
    depends_on = [ azurerm_linux_virtual_machine.main ]
}
