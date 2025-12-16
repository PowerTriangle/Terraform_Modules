data "azurerm_monitor_diagnostic_categories" "categories" {
  resource_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_monitor_diagnostic_setting" "logs" {
  count                      = var.central_audit_law_workspace_id != null ? 1 : 0
  name                       = "keyvault-audit-law"
  target_resource_id         = azurerm_key_vault.key_vault.id
  log_analytics_workspace_id = var.central_audit_law_workspace_id

  dynamic "enabled_log" {
    iterator = log
    for_each = [for category in data.azurerm_monitor_diagnostic_categories.categories.log_category_types :
      {
        category = category
      }
    ]
    content {
      category = log.value.category
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}

resource "azurerm_monitor_diagnostic_setting" "metrics" {
  count                      = var.mgmt_law_workspace_id != null ? 1 : 0
  name                       = "keyvault-mgmt-law"
  target_resource_id         = azurerm_key_vault.key_vault.id
  log_analytics_workspace_id = var.mgmt_law_workspace_id

  dynamic "metric" {
    iterator = metric
    for_each = [for category in data.azurerm_monitor_diagnostic_categories.categories.metrics : {
      category = category
    }]

    content {
      category = metric.value.category
      enabled  = true
    }
  }
}
