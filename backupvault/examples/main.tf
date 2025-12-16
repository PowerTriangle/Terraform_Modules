resource "azurerm_resource_group" "dylan_rg" {
  name     = "example_rg"
  location = "UK South"
}


module "backupvault" {
  source                                      = "../."
  backup_vault_name           = "test1"
  backup_vault_location                       = "UK South"
  backup_vault_resource_group_name =   azurerm_resource_group.dylan_rg.name
  backup_vault_datastore_type                 = "VaultStore"
  backup_vault_redundancy                     = "LocallyRedundant"
  backup_vault_soft_delete       = "Off" 
  backupvault_disk_snapshot_contributor_role_scope_ids = ["${azurerm_resource_group.dylan_rg.id}"]
  backupvault_disk_restore_operator_role_scope_ids = ["${azurerm_resource_group.dylan_rg.id}"]
  backupvault_disk_backup_reader_role_scope_ids = ["${azurerm_resource_group.dylan_rg.id}"]
  backupvault_storage_account_backup_contributor_role_scope_ids = ["${azurerm_resource_group.dylan_rg.id}"]
  backupvault_reader_role_scope_ids = ["${azurerm_resource_group.dylan_rg.id}"]
  backupvault_postgresql_flexible_LTRBackup_scope_ids = ["${azurerm_resource_group.dylan_rg.id}"]
  backupvault_storageblobdatacontributor_role_scope_ids = ["${azurerm_resource_group.dylan_rg.id}"]
  backupvault_datadiskoperator_role_scope_ids = ["${azurerm_resource_group.dylan_rg.id}"]
  backupvault_keyvaultsecretsuser_role_scope_ids = ["${azurerm_resource_group.dylan_rg.id}"]
  # enable_mysql_flexible_backup_permissions = true
  # backupvault_mysql_flexible_reader_role_scope_ids = ["${azurerm_resource_group.dylan_rg.id}"]
  # backupvault_mysql_flexible_MySQL_Backup_And_Export_Operator_role_scope_ids = ["${azurerm_resource_group.dylan_rg.id}"]
  # backupvault_mysql_flexible_storageblobdatacontributor_role_scope_ids = ["${azurerm_resource_group.dylan_rg.id}"]

  
  azure_blobs_backup_instances = {
    blob1 = {
      name = "test12"
      location = "UK South"
      storage_account_id = azurerm_storage_account.example.id
      backup_policy_id = module.backupvault.backup_policy_blob_storage_id[0]
      storage_account_container_names = ["test"]
    }
  }
  disks_backup_instances = {
    disk1 = {
      name = "test"
      disk_id = data.azurerm_managed_disk.existing.id
      location = "UK South"
      snapshot_resource_group_name = azurerm_resource_group.dylan_rg.name
       backup_policy_id = module.backupvault.backup_policy_disk_id[0]
    }
  }
  kubernetes_backup_instances = {
    kubernetes1 = {
      name = "test2"
      location = "UK South"
      snapshot_resource_group_name = azurerm_resource_group.dylan_rg.name
      kubernetes_cluster_id  = azurerm_kubernetes_cluster.example.id
      backup_policy_id = module.backupvault.backup_policy_kubernetes_id[0]
    }
  }
  postgresql_flexible_backup_instances = {
    postgresql_flex = {
      name = "test3"
      location = "UK South"
      backup_policy_id = module.backupvault.backup_policy_postgresql_flexible_id[0]
      server_id = azurerm_postgresql_flexible_server.example.id
    }
  }
  postgresql_backup_instances = {
    postgresql = {
      name = "test20"
      location = "UK South"
      database_id = azurerm_postgresql_database.example.id
      backup_policy_id = module.backupvault.backup_policy_postgresql_id[0]
      database_credential_key_vault_secret_id = azurerm_key_vault_secret.example.versionless_id
    }
  }
  # mysql_flexible_backup_instances = { #mysql_flexible server takes a long time to spin up
  #   mysql_flex = {
  #     name = "test4"
  #     location = "UK South"
  #     backup_policy_id = module.backupvault.backup_policy_mysql_flexible_id[0]
  #     server_id = azurerm_mysql_flexible_server.example.id
  #   }
  # }
  blob_backup_policies = {
    Daily-blob = {
      name = "backup8"
      backup_repeating_time_intervals    = ["R/2021-05-19T06:33:16+00:00/PT4H"]
      timezone                           = "UTC"
      vault_default_retention_duration   = "P7D"
      enable_retention_rules             = true
      retention_rules = {
        rule1 = {
         name     = "Weekly"
         duration = "P7D"
         priority = 20
         criteria = {
           absolute_criteria = "FirstOfWeek"
         }
         life_cycle = {
          data_store_type = "VaultStore"
          duration        = "P7D"
         }
        }
      }
    }
  }
  disk_backup_policies = {
    Daily-2200-52W-YZ = {
      name = "backup7"
      backup_repeating_time_intervals    = ["R/2021-05-19T06:33:16+00:00/PT4H"]
      timezone                           = "UTC"
      default_retention_duration         = "P7D"
      enable_retention_rules             = true
      retention_rules = {
        rule1 = {
         name     = "Weekly"
         duration = "P7D"
         priority = 20
         criteria = {
           absolute_criteria = "FirstOfWeek"
         }
        }
      }
    }
  }
  kubernetes_backup_policies = {
    Daily-2200-52W-Y = {
      name = "backup5"
      resource_group_name = "${azurerm_resource_group.dylan_rg.name}"
      backup_repeating_time_intervals    = ["R/2021-05-19T06:33:16+00:00/PT4H"]
      timezone                           = "UTC"
      default_retention_duration         = "P7D"
      default_retention_rule = {
        life_cycle = {
          data_store_type = "OperationalStore"
          duration        =  "P7D"
        }
      }
      enable_retention_rules             = true
      retention_rules = {
         rule1 = {
         name     = "Weekly"
         priority = 20
         criteria = {
           absolute_criteria = "FirstOfWeek"
          #  days_of_week      = ["Monday"]
         }
         life_cycle = {
          data_store_type = "OperationalStore"
          duration        = "P7D"
         }
        }
      }
    }
  }
  postgresql_flexible_backup_policies = {
    Daily-2200-52W-YW = {
      name = "backup12"
      backup_repeating_time_intervals    = ["R/2021-05-19T06:33:16+00:00/PT4H"]
      timezone                           = "UTC"
      default_retention_rule = {
        life_cycle = {
          data_store_type = "VaultStore"
          duration        =  "P7D"
        }
      }
      enable_retention_rules             = true
      retention_rules = {
         rule1 = {
         name     = "Weekly"
         priority = 20
         criteria = {
           days_of_week           = ["Thursday"]
           scheduled_backup_times = ["2021-05-23T02:30:00Z"]
         }
         life_cycle = {
          data_store_type = "VaultStore"
          duration        = "P7D"
         }
        }
      }
    }
  }
    postgresql_backup_policies = {
    Daily-2200-52W-YW = {
      name = "backup20"
      resource_group_name = "${azurerm_resource_group.dylan_rg.name}"
      backup_repeating_time_intervals    = ["R/2021-05-19T06:33:16+00:00/PT4H"]
      timezone                           = "UTC"
      default_retention_duration         = "P7D"
      enable_retention_rules             = true
      retention_rules = {
         rule1 = {
         name     = "Weekly"
         priority = 20
         duration = "P7D"
         criteria = {
           days_of_week           = ["Thursday"]
           scheduled_backup_times = ["2021-05-23T02:30:00Z"]
         }
        }
      }
    }
  }
  # mysql_flexible_backup_policies = {
  #   Daily-2200-52W-Y = {
  #     name = "backup1"
  #     backup_repeating_time_intervals    = ["R/2021-05-19T06:33:16+00:00/PT4H"]
  #     timezone                           = "UTC"
  #     default_retention_rule = {
  #       life_cycle = {
  #         data_store_type = "VaultStore"
  #         duration        =  "P1D"
  #       }
  #     }
  #     enable_retention_rules             = true
  #     retention_rules = {
  #        rule1 = {
  #        name     = "Weekly"
  #        priority = 20
  #        criteria = {
  #          absolute_criteria = "FirstOfWeek"
  #          days_of_week      = ["Monday"]
  #        }
  #        life_cycle = {
  #         data_store_type = "VaultStore"
  #         duration        = "P30D"
  #        }
  #       }
  #     }
  #   }
  # }
  depends_on = [azurerm_managed_disk.example, azurerm_storage_account.example, azurerm_kubernetes_cluster.example, azurerm_postgresql_flexible_server.example, azurerm_postgresql_server.example, azurerm_postgresql_database.example, azurerm_postgresql_firewall_rule.example]
}

resource "azurerm_managed_disk" "example" {
  name                 = "test"
  location             = azurerm_resource_group.dylan_rg.location
  resource_group_name  = azurerm_resource_group.dylan_rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
}

resource "azurerm_storage_account" "example" {
  name                     = "sa123dylan"
  resource_group_name      = azurerm_resource_group.dylan_rg.name
  location                 = azurerm_resource_group.dylan_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "example"
  location            = azurerm_resource_group.dylan_rg.location
  resource_group_name = azurerm_resource_group.dylan_rg.name
  dns_prefix          = "dns"

  default_node_pool {
    name                    = "default"
    node_count              = 1
    vm_size                 = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# # resource "azurerm_mysql_flexible_server" "example" {
# #   name                   = "example-mysqlfs-dylantest"
# #   resource_group_name    = azurerm_resource_group.dylan_rg.name
# #   location               = azurerm_resource_group.dylan_rg.location
# #   administrator_login    = "adminTerraform"
# #   administrator_password = "QAZwsx123"
# #   version                = "8.0.21"
# #   sku_name               = "B_Standard_B1s"
# #   zone                   = "1"
# # }

resource "azurerm_postgresql_flexible_server" "example" {
  name                   = "example-postgresqlfs-dylantest"
  resource_group_name    = azurerm_resource_group.dylan_rg.name
  location               = azurerm_resource_group.dylan_rg.location
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  storage_mb             = 32768
  version                = "12"
  sku_name               = "GP_Standard_D4s_v3"
  zone                   = "2"
}

resource "azurerm_postgresql_server" "example" {
  
  name                = "dylan-example-svr-123"
  location            = azurerm_resource_group.dylan_rg.location
  resource_group_name = azurerm_resource_group.dylan_rg.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true


  administrator_login          = "psqladmin"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "example" {
  name                = "dylan-example-123-db"
  resource_group_name = azurerm_resource_group.dylan_rg.name
  server_name         = azurerm_postgresql_server.example.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "example" {
  name                = "AllowAllWindowsAzureIps"
  resource_group_name = azurerm_resource_group.dylan_rg.name
  server_name         = azurerm_postgresql_server.example.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_key_vault" "example" {

  name                       = "dylan-example-123-kv"
  location                   = azurerm_resource_group.dylan_rg.location
  resource_group_name        = azurerm_resource_group.dylan_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = ["Create", "Get"]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }

  access_policy {
    tenant_id = module.backupvault.backup_vault_identity[0].tenant_id
    object_id = module.backupvault.backup_vault_identity[0].principal_id

    key_permissions = ["Create", "Get"]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

resource "azurerm_key_vault_secret" "example" {
  name         = "example"
  value        = "Server=${azurerm_postgresql_server.example.name}.postgres.database.azure.com;Database=${azurerm_postgresql_database.example.name};Port=5432;User Id=psqladmin@${azurerm_postgresql_server.example.name};Password=H@Sh1CoR3!;Ssl Mode=Require;"
  key_vault_id = azurerm_key_vault.example.id
}
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_postgresql
