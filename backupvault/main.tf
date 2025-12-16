resource "azurerm_data_protection_backup_vault" "backup_vault" {
  name                       = var.backup_vault_name
  resource_group_name        = var.backup_vault_resource_group_name
  location                   = var.backup_vault_location
  datastore_type             = var.backup_vault_datastore_type
  redundancy                 = var.backup_vault_redundancy
  retention_duration_in_days = var.backup_vault_retention_duration_in_days
  # cross_region_restore_enabled = var.backup_vault_redundancy == "GeoRedundant" ? var.backup_vault_cross_region_restore_enabled : null
  # immutability                 = var.backup_vault_immutability
  soft_delete                = var.backup_vault_soft_delete
  tags                       = var.tags
  identity {
    type = "SystemAssigned"
  }
}

#############################################################
########Azure RBAC Role Assignments for Backup Vault#########
#############################################################

########Disk Backup permissions#########################
##Disk Snapshot Contributor role applied to resource group where Backup vault disks 
#snapshots will be stored  
resource "azurerm_role_assignment" "backupvault_disk_snapshot_contributor_role" {
  for_each             = toset(var.backupvault_disk_snapshot_contributor_role_scope_ids)
  scope                = each.key
  role_definition_name = "Disk Snapshot Contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault.identity[0].principal_id
}

##Disk Backup Reader permission applied to Disks you want to backup
resource "azurerm_role_assignment" "backupvault_disk_reader_role" {
  for_each             = toset(var.backupvault_disk_backup_reader_role_scope_ids)
  scope                = each.key
  role_definition_name = "Disk Backup Reader"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault.identity[0].principal_id
}

##Disk Restore Operator permission applied to a resource group where you would restore your disks to
resource "azurerm_role_assignment" "backupvault_disk_restore_operator_role" {
  for_each             = toset(var.backupvault_disk_restore_operator_role_scope_ids)
  scope                = each.key
  role_definition_name = "Disk Restore Operator"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault.identity[0].principal_id
}

##Required roles for backup vault for disk backups are defined below:
##https://learn.microsoft.com/en-us/azure/backup/backup-managed-disks
##https://learn.microsoft.com/en-us/azure/backup/restore-managed-disks
#######

##permissions required for backing up and restoring storage account blobs using backup vault#####
##Apply Storage account backup contributor role to Storage account containing the blob you want to backup and restore to.
resource "azurerm_role_assignment" "backupvault_storage_account_backup_contributor_role" {
  for_each             = toset(var.backupvault_storage_account_backup_contributor_role_scope_ids)
  scope                = each.key
  role_definition_name = "Storage account backup contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault.identity[0].principal_id
}


#Apply reader role to the resource group for the resources you want to backup such as disks, servers, kubernetes.
resource "azurerm_role_assignment" "backupvault_reader_role" {
  for_each             = toset(var.backupvault_reader_role_scope_ids)
  scope                = each.key
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault.identity[0].principal_id
}

#mysql_flexible server backup is still in preview mode therefore commenting out until it has been released
##Apply MySQL Backup And Export Operator role to the scope of the mysql server
# resource "azurerm_role_assignment" "backupvault_MySQL_Backup_And_Export_Operator_Role" {
#   for_each             = toset(var.backupvault_MySQL_Backup_And_Export_Operator_role_scope_ids)
#   scope                = each.key
#   role_definition_name = "MySQL Backup And Export Operator"
#   principal_id         = azurerm_data_protection_backup_vault.backup_vault.identity[0].principal_id
# }

##Apply these permissions to the target storage account you want to restore your database/files to. 
resource "azurerm_role_assignment" "backupvault_storageblobdatacontributor_role" {
  for_each             = toset(var.backupvault_storageblobdatacontributor_role_scope_ids)
  scope                = each.key
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault.identity[0].principal_id
}


##Apply these permissions on the Azure Key vault that contain the credentials to the Azure postgresql server to allow Azure Backup vault to connect to the database.
resource "azurerm_role_assignment" "backupvault_keyvaultsecretsuser_role" {
  for_each             = toset(var.backupvault_keyvaultsecretsuser_role_scope_ids)
  scope                = each.key
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault.identity[0].principal_id
}

##Apply these Flexible Server Long Term Retention Backup permissions for the Azure postgresql flexible servers you want to backup
resource "azurerm_role_assignment" "backupvault_postgresql_flexible_LTRBackup_role" {
  for_each             = toset(var.backupvault_postgresql_flexible_LTRBackup_scope_ids)
  scope                = each.key
  role_definition_name = "PostgreSQL Flexible Server Long Term Retention Backup Role"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault.identity[0].principal_id
}


##Apply these permissions on kubernetes snapshot resource group
resource "azurerm_role_assignment" "backupvault_datadiskoperator_role" {
  for_each             = toset(var.backupvault_datadiskoperator_role_scope_ids)
  scope                = each.key
  role_definition_name = "Data Operator for Managed Disks"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault.identity[0].principal_id
}


##############################################################
######END OF AZURE RBAC Backup vault permissions##############
##############################################################

resource "azurerm_data_protection_backup_policy_disk" "backup_policy" {
  for_each            = var.disk_backup_policies
  name                = each.value.name
  vault_id            = azurerm_data_protection_backup_vault.backup_vault.id

  backup_repeating_time_intervals = try(each.value.backup_repeating_time_intervals, ["R/2021-11-01T03:00:00+00:00/P1D"]) #follow ISO 8601 repeating time interval
  default_retention_duration      = try(each.value.default_retention_duration, "P7D") #ISO 8601 duration format
  time_zone                       = try(each.value.timezone, "UTC")

  dynamic "retention_rule" {
    for_each = each.value.enable_retention_rules ? each.value.retention_rules : {}
    content {
     name = retention_rule.value.name
     duration = retention_rule.value.duration
     priority = retention_rule.value.priority
     criteria {
        absolute_criteria = retention_rule.value.criteria["absolute_criteria"]
      } 
     }
 }  
}


resource "azurerm_data_protection_backup_policy_blob_storage" "backup_policy" {
  for_each                               = var.blob_backup_policies
  name                                   = each.value.name
  vault_id                               = azurerm_data_protection_backup_vault.backup_vault.id
  operational_default_retention_duration = try(each.value.operational_default_retention_duration,"P7D")
  backup_repeating_time_intervals        = try(each.value.backup_repeating_time_intervals, ["R/2021-11-01T03:00:00+00:00/P1D"])
  vault_default_retention_duration       = try(each.value.vault_default_retention_duration, "P7D")
  time_zone                              = try(each.value.timezone, "UTC")

  dynamic "retention_rule" {
    for_each = each.value.enable_retention_rules ? each.value.retention_rules : {}
    content {
      name = retention_rule.value.name
      priority = retention_rule.value.priority
      life_cycle {
        data_store_type = retention_rule.value.life_cycle["data_store_type"]
        duration        = retention_rule.value.life_cycle["duration"]
      }
      criteria {
        absolute_criteria = retention_rule.value.criteria["absolute_criteria"]
        days_of_month     = retention_rule.value.criteria["days_of_month"]
        days_of_week      = retention_rule.value.criteria["days_of_week"]
        months_of_year    = retention_rule.value.criteria["months_of_year"]
        weeks_of_month    = retention_rule.value.criteria["weeks_of_month"]
        scheduled_backup_times = retention_rule.value.criteria["scheduled_backup_times"]
      }
    }
  }  
}

resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "backup_policy" {
  for_each            = var.kubernetes_backup_policies
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  vault_name          = azurerm_data_protection_backup_vault.backup_vault.name

  backup_repeating_time_intervals = try(each.value.backup_repeating_time_intervals, ["R/2021-11-01T03:00:00+00:00/P1D"])
  time_zone                       = try(each.value.timezone, "UTC")

  default_retention_rule {
    life_cycle {
      duration        = each.value.default_retention_rule.life_cycle["duration"]
      data_store_type = each.value.default_retention_rule.life_cycle["data_store_type"]
    }
  }
  
  dynamic "retention_rule" {
    for_each = each.value.enable_retention_rules ? each.value.retention_rules : {}
    content {
      name     = retention_rule.value.name
      priority = retention_rule.value.priority
      life_cycle {
      duration        = retention_rule.value.life_cycle["duration"] #string required
      data_store_type = retention_rule.value.life_cycle["data_store_type"] #string required
    }

    criteria {
      absolute_criteria = retention_rule.value.criteria["absolute_criteria"] #optional string list
      days_of_week      = retention_rule.value.criteria["days_of_week"] #optional string list 
      months_of_year    = retention_rule.value.criteria["months_of_year"] #optional string list
      weeks_of_month    = retention_rule.value.criteria["weeks_of_month"] #optional string list
      scheduled_backup_times = retention_rule.value.criteria["scheduled_backup_times"] #optional string list
    }
    }
    
  }

}

#mysql_flexible server backup is still in preview mode therefore commenting out until it has been released
# resource "azurerm_data_protection_backup_policy_mysql_flexible_server" "backup_policy" {
#   for_each                        = var.mysql_flexible_backup_policies
#   name                            = each.value.name
#   vault_id                        = azurerm_data_protection_backup_vault.backup_vault.id
#   backup_repeating_time_intervals = try(each.value.backup_repeating_time_intervals, ["R/2021-11-01T03:00:00+00:00/P1D"])     
#   time_zone                       = try(each.value.timezone, "UTC")
  
#   default_retention_rule {
#     life_cycle {
#       duration        = each.value.default_retention_rule.life_cycle["duration"]
#       data_store_type = each.value.default_retention_rule.life_cycle["data_store_type"]
#     }
#   }

#   dynamic "retention_rule" {
#     for_each = each.value.enable_retention_rules ? each.value.retention_rules : {}
#     content {
#       name     = retention_rule.value.name
#       priority = retention_rule.value.priority
#       life_cycle {
#       duration        = retention_rule.value.life_cycle["duration"] #string required
#       data_store_type = retention_rule.value.life_cycle["data_store_type"] #string required
#     }

#     criteria {
#       absolute_criteria = retention_rule.value.criteria["absolute_criteria"] #optional string list
#       days_of_week      = retention_rule.value.criteria["days_of_week"] #optional string list
#       months_of_year    = retention_rule.value.criteria["months_of_year"] #optional string list
#       weeks_of_month    = retention_rule.value.criteria["weeks_of_month"] #optional string list
#       scheduled_backup_times = retention_rule.value.criteria["scheduled_backup_times"] #optional string list
#     }
#     }
    
#   }
# }


resource "azurerm_data_protection_backup_policy_postgresql" "backup_policy" {
  for_each            = var.postgresql_backup_policies
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  vault_name          = azurerm_data_protection_backup_vault.backup_vault.name

  backup_repeating_time_intervals = try(each.value.backup_repeating_time_intervals, ["R/2021-11-01T03:00:00+00:00/P1D"])
  time_zone                       = try(each.value.timezone, "UTC")
  default_retention_duration      = try(each.value.default_retention_duration, "P7D")

  dynamic "retention_rule" {
    for_each = each.value.enable_retention_rules ? each.value.retention_rules : {}
    content {
      name     = retention_rule.value.name
      priority = retention_rule.value.priority
      duration = retention_rule.value.duration
    
    criteria {
      absolute_criteria = retention_rule.value.criteria["absolute_criteria"] #optional string list
      days_of_week      = retention_rule.value.criteria["days_of_week"] #optional string list
      months_of_year    = retention_rule.value.criteria["months_of_year"] #optional string list
      weeks_of_month    = retention_rule.value.criteria["weeks_of_month"] #optional string list
      scheduled_backup_times = retention_rule.value.criteria["scheduled_backup_times"] #optional string list
    }
    }
    
  }

}

resource "azurerm_data_protection_backup_policy_postgresql_flexible_server" "backup_policy" {
  for_each                        = var.postgresql_flexible_backup_policies
  name                            = each.value.name
  vault_id                        = azurerm_data_protection_backup_vault.backup_vault.id
  backup_repeating_time_intervals = try(each.value.backup_repeating_time_intervals, ["R/2021-11-01T03:00:00+00:00/P1D"])
  time_zone                       = try(each.value.timezone, "UTC")

  default_retention_rule {
    life_cycle {
      duration        = each.value.default_retention_rule.life_cycle["duration"]
      data_store_type = each.value.default_retention_rule.life_cycle["data_store_type"]
    }
  }

  dynamic "retention_rule" {
    for_each = each.value.enable_retention_rules ? each.value.retention_rules : {}
    content {
      name     = retention_rule.value.name
      priority = retention_rule.value.priority
      life_cycle {
        duration        = retention_rule.value.life_cycle["duration"] #string required
        data_store_type = retention_rule.value.life_cycle["data_store_type"] #string required
      }
    
    criteria {
      absolute_criteria = retention_rule.value.criteria["absolute_criteria"] #optional string list
      days_of_week      = retention_rule.value.criteria["days_of_week"] #optional string list
      months_of_year    = retention_rule.value.criteria["months_of_year"]#optional string list
      weeks_of_month    = retention_rule.value.criteria["weeks_of_month"] #optional string list
      scheduled_backup_times = retention_rule.value.criteria["scheduled_backup_times"]#optional string list
    }
    }
    
  }
}


#for each was inspired by terraform-module-az-recovery-services-vault module#

###backup vault instances##
##Disk (s) to backup using backup vault##
resource "azurerm_data_protection_backup_instance_disk" "backup_instance" {
  for_each                     = var.disks_backup_instances
  name                         = each.value.name
  location                     = each.value.location
  vault_id                     = azurerm_data_protection_backup_vault.backup_vault.id
  disk_id                      = each.value.disk_id
  snapshot_resource_group_name = each.value.snapshot_resource_group_name
  backup_policy_id             = each.value.backup_policy_id
}                               


resource "azurerm_data_protection_backup_instance_blob_storage" "backup_instance" {
  for_each           = var.azure_blobs_backup_instances
  name               = each.value.name
  vault_id           = azurerm_data_protection_backup_vault.backup_vault.id
  location           = each.value.location
  storage_account_id = each.value.storage_account_id
  backup_policy_id   = each.value.backup_policy_id
  storage_account_container_names = each.value.storage_account_container_names
}

resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "backup_instance" {
  for_each                     = var.kubernetes_backup_instances
  name                         = each.value.name
  location                     = each.value.location
  vault_id                     = azurerm_data_protection_backup_vault.backup_vault.id
  kubernetes_cluster_id        = each.value.kubernetes_cluster_id
  snapshot_resource_group_name = each.value.snapshot_resource_group_name
  backup_policy_id             = each.value.backup_policy_id

  backup_datasource_parameters {
    excluded_namespaces              = try(each.value.backup_datasource_parameters.excluded_namespaces, [])
    excluded_resource_types          = try(each.value.backup_datasource_parameters.excluded_resource_types, [])
    cluster_scoped_resources_enabled = try(each.value.backup_datasource_parameters.cluster_scoped_resources_enabled, false)
    included_namespaces              = try(each.value.backup_datasource_parameters.included_namespaces, [])
    included_resource_types          = try(each.value.backup_datasource_parameters.included_resource_types, [])
    label_selectors                  = try(each.value.backup_datasource_parameters.label_selectors, [])
    volume_snapshot_enabled          = try(each.value.backup_datasource_parameters.volume_snapshot_enabled, false)
  }
   
}

resource "azurerm_data_protection_backup_instance_postgresql" "backup_instance" {
  for_each                                = var.postgresql_backup_instances
  name                                    = each.value.name
  location                                = each.value.location
  vault_id                                = azurerm_data_protection_backup_vault.backup_vault.id
  database_id                             = each.value.database_id
  backup_policy_id                        = each.value.backup_policy_id
  database_credential_key_vault_secret_id = each.value.database_credential_key_vault_secret_id
}

resource "azurerm_data_protection_backup_instance_postgresql_flexible_server" "backup_instance" {
  for_each         = var.postgresql_flexible_backup_instances
  name             = each.value.name
  location         = each.value.location
  vault_id         = azurerm_data_protection_backup_vault.backup_vault.id
  server_id        = each.value.server_id
  backup_policy_id = each.value.backup_policy_id
}

#mysql_flexible server backup is still in preview mode therefore commenting out until it has been released
# resource "azurerm_data_protection_backup_instance_mysql_flexible_server" "backup_instance" {
#   for_each         = var.mysql_flexible_backup_instances
#   name             = each.value.name
#   location         = each.value.location
#   vault_id         = azurerm_data_protection_backup_vault.backup_vault.id
#   server_id        = each.value.server_id
#   backup_policy_id = each.value.backup_policy_id
# }

# Terraform registry link for the inital creation of the backup vault.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault

# Terraform registry link for the creation of the backup vault policy
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_disk

# Terraform registry link for data protection backup instance disk.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk