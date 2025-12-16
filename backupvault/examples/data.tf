data "azurerm_managed_disk" "existing" {
  name                = "test"
  resource_group_name = azurerm_resource_group.dylan_rg.name
 depends_on = [ azurerm_managed_disk.example ]
}

data "azurerm_client_config" "current" {
}