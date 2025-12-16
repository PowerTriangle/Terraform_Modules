variable "disk_backup_policies" {
  description = "Manages Disk Backup Policies"
  type        = map(object({
    name = string
    backup_repeating_time_intervals = list(string)
    default_retention_duration = string
    retention_rules            = optional(map(object({
      name = string
      priority = number
      duration = string
      criteria = object({
        absolute_criteria = optional(string)
      })
    })))
    timezone                   = optional(string)
    enable_retention_rules     = bool
  }))

  default     = {}
}

variable "blob_backup_policies" {
  description = "Manages Blob Storage Backup Policies"
  type        = map(object({
    name = string
    operational_default_retention_duration = optional(string)
    backup_repeating_time_intervals = optional(list(string))
    vault_default_retention_duration = optional(string)
    retention_rules            =  optional(map(object({
      name = string
      priority = number
      duration = string
      life_cycle = object({
        duration = string
        data_store_type = string
      })
      criteria = object({
        absolute_criteria = optional(string)
        days_of_month     = optional(set(number))
        days_of_week = optional(set(string))
        months_of_year = optional(set(string))
        weeks_of_month = optional(set(string))
        scheduled_backup_times = optional(list(string))
      })
    })))
    timezone                   = optional(string)
    enable_retention_rules     = bool
  }))
  default     = {}
}

variable "kubernetes_backup_policies" {
  description = "Manages Kubernetes Backup Policies"
  type        = map(object({
    name = string
    resource_group_name = string
    backup_repeating_time_intervals = list(string)
    default_retention_rule = object({
      life_cycle = object({
        data_store_type = string
        duration        = string
      })
    })
    retention_rules = optional(map(object({
      name = string
      priority = number
      life_cycle = object({
        duration = string
        data_store_type = string
      })
      criteria = object({
        absolute_criteria = optional(string)
        days_of_week = optional(set(string))
        months_of_year = optional(set(string))
        weeks_of_month = optional(set(string))
        scheduled_backup_times = optional(list(string))
      })
    })))
    timezone                   = optional(string)
    enable_retention_rules     = bool
  }))
  default     = {}
}

# #mysql_flexible server backup is still in preview mode therefore commenting out until it has been released
# variable "mysql_flexible_backup_policies" {
#   description = "Manages Mysql Flexible Server Backup Policies"
#   type        = map(object({
#     name = string
#     backup_repeating_time_intervals = list(string)
#     default_retention_rule     = object({
#       life_cycle = object({
#         data_store_type = string
#         duration        = string
#       })
#     })
#     retention_rules            = optional(map(object({
#       name = string
#       priority = number
#       life_cycle = object({
#         duration = string
#         data_store_type = string
#       })
#       criteria = object({
#         absolute_criteria = optional(string)
#         days_of_week = optional(set(string))
#         months_of_year = optional(set(string))
#         weeks_of_month = optional(set(string))
#         scheduled_backup_times = optional(list(string))
#       })
#     })))
#     timezone                   = optional(string)
#     enable_retention_rules     = bool
#   }))
#   default     = {}
# }

variable "postgresql_backup_policies" {
  description = "Manages Postgresql backup policies"
  type        = map(object({
    name = string
    resource_group_name = string
    backup_repeating_time_intervals = list(string)
    default_retention_duration = string
    retention_rules            = optional(map(object({
      name = string
      priority = number
      duration = string
      criteria = object({
        absolute_criteria = optional(string)
        days_of_week = optional(set(string))
        months_of_year = optional(set(string))
        weeks_of_month = optional(set(string))
        scheduled_backup_times = optional(list(string))
      })
    })))
    timezone                   = optional(string)
    enable_retention_rules     = bool
  }))
  default     = {}
}

variable "postgresql_flexible_backup_policies" {
  description = "Manages Postgresql Flexible Server Backup Policies"
  type        = map(object({
    name = string
    backup_repeating_time_intervals = list(string)
    default_retention_rule     =  object({
      life_cycle = object({
        data_store_type = string
        duration        = string
      })
    })
    retention_rules            = optional(map(object({
      name = string
      priority = number
      life_cycle = object({
        duration = string
        data_store_type = string
      })
      criteria = object({
        absolute_criteria = optional(string)
        days_of_week = optional(set(string))
        months_of_year = optional(set(string))
        weeks_of_month = optional(set(string))
        scheduled_backup_times = optional(list(string))
      })
    })))
    timezone                   = optional(string)
    enable_retention_rules     = bool
  }))
  default     = {}
}


variable "disks_backup_instances" {
  description = "Manages Disk Backup Instances"
  type        = map(object({
    name                         = string
    location                     = string
    disk_id                      = string
    snapshot_resource_group_name = string
    backup_policy_id             = string
  }))
  default     = {}
}

variable "azure_blobs_backup_instances" {
  description = "Manages Azure Blob Storage Backup Instances"
  type        = map(object({
    name                            = string
    location                        = string
    storage_account_id              = string
    storage_account_container_names = optional(list(string))
    backup_policy_id                = string
  }))
  default     = {}
}

variable "kubernetes_backup_instances" {
  description = "Manages Kubernetes Backup Instances"
  type        = map(object({
    name                            = string
    location                        = string
    kubernetes_cluster_id           = string
    snapshot_resource_group_name    = string
    backup_policy_id                = string
    backup_datasource_parameters    = optional(object({
      excluded_namespaces = optional(list(string))
      excluded_resource_types = optional(list(string)) 
      cluster_scoped_resources_enabled = optional(bool, false)
      included_namespaces = optional(list(string))
      included_resource_types  = optional(list(string))
      label_selectors = optional(list(string))
      volume_snapshot_enabled  = optional(bool, false)
      }))
  }))

  default     = {}

}

variable "postgresql_backup_instances" {
  description = "Manages Postgresql Backup Instances"
  type        = map(object({
    name                                       = string
    location                                   = string
    database_id                                = string
    database_credential_key_vault_secret_id    = optional(string)
    backup_policy_id                           = string
  }))
  default     = {}
}

variable "postgresql_flexible_backup_instances" {
  description = "Manages Postgresql Flexible Server Backup Instances"
  type        = map(object({
    name                                       = string
    location                                   = string
    server_id                                  = string
    backup_policy_id                           = string
  }))
  default     = {}
}

# #mysql_flexible server backup is still in preview mode therefore commenting out until it has been released
# variable "mysql_flexible_backup_instances" {
#   description = "Manages Mysql Flexible Server Backup Instances"
#   type        = map(object({
#     name                                       = string
#     location                                   = string
#     server_id                                  = string
#     backup_policy_id                           = string
#   }))
#   default     = {}
# }

variable "backup_vault_location" {
  description = "Azure region of azure backup vault"
  type        = string
  default     = "UK South"
}

# variable "enable_disk_backup_permissions" {
#   description = "Bool Value to determine whether to enable azure backup vault permissions related to disk backups"
#   type        = bool
#   default     = false
# }

# variable "enable_blob_backup_permissions" {
#   description = "Bool Value to determine whether to enable azure backup vault permissions related to blob backups"
#   type        = bool
#   default     = false
# }

# variable "enable_postgresql_backup_permissions" {
#   description = "Bool Value to determine whether to enable azure backup vault permissions related to postgresql backups"
#   type        = bool
#   default     = false
# }

# variable "enable_kubernetes_backup_permissions" {
#   description = "Bool Value to determine whether to enable azure backup vault permissions related to kubernetes backups"
#   type        = bool
#   default     = false
# }

# variable "enable_mysql_flexible_backup_permissions" {
#   description = "Bool Value to determine whether to enable azure backup vault permissions related to mysql flexible server backups"
#   type        = bool
#   default     = false
# }

# variable "enable_postgresql_flexible_backup_permissions" {
#   description = "Bool Value to determine whether to enable azure backup vault permissions related to postgresql flexible server backups"
#   type        = bool
#   default     = false
# }

variable "backup_vault_name" {
  description = "name of azure backup vault"
  type        = string
}

variable "backup_vault_redundancy" {
  description = "redundancy of azure backup vault"
  type        = string
}

variable "backup_vault_retention_duration_in_days" {
  description = "the number of days for which deleted data is retained before being permanently deleted"
  type        = number
  default     = 14
}

variable "backup_vault_soft_delete" {
  description = "The state of soft delete for this Backup Vault"
  type        = string
  default     = "On"
}

variable "backup_vault_cross_region_restore_enabled" {
  description = "Whether to enable cross-region restore for the Backup Vault, can only be specified when redundancy is GeoRedundant"
  type        = bool
  default     = false
}

variable "backup_vault_immutability" {
  description = "The state of immutability for this Backup Vault"
  type        = string
  default     = "Disabled"
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the Backup Vault."
  type = map(any)
  default = {}
}
variable "backup_vault_datastore_type" {
  description = "backup_vault_datastore_type"
  type        = string
  default     = "VaultStore"
}

variable "backup_vault_resource_group_name" {
  description = "azure backup vault resource group name"
  type        = string
}

##Disk Snapshot Contributor role applied to resource group where Backup vault disks snapshots will be stored  
variable "backupvault_disk_snapshot_contributor_role_scope_ids" {
  description = "backup_vault disk snapshot contributor role scope ids of where the role is applied e.g resource group ids where disk snapshots made from backupvault can be stored"
  type        = list(string)
  default     = []
}

##Disk Backup Reader permission applied to Disks you want to backup
variable "backupvault_disk_backup_reader_role_scope_ids" {
  description = "backup_vault disk backup reader role scope ids of where the role is applied e.g disks ids to allow backup vault to read disks to enable disk backups"
  type        = list(string)
  default     = []
}

##Disk Restore Operator permission applied to a resource group where you would restore your disks to
variable "backupvault_disk_restore_operator_role_scope_ids" {
  description = "backup_vault disk restore operator role scope ids of where the role is applied e.g resource group ids where disk snapshots can be restored to disks"
  type        = list(string)
  default     = []
}

variable "backupvault_storage_account_backup_contributor_role_scope_ids" {
  description = "backup_vault storage account backup contributor role scope ids of where the role is applied e.g Storage account containing the blob you want to backup and restore to"
  type        = list(string)
  default     = []
}

variable "backupvault_reader_role_scope_ids" {
  description = "backup_vault reader role scope ids of where the role is applied e.g Apply reader role to the resource group of instances you want to backup"
  type        = list(string)
  default     = []
}

#mysql_flexible server backup is still in preview mode therefore commenting out until it has been released
# variable "backupvault_MySQL_Backup_And_Export_Operator_role_scope_ids" {
#   description = "backup_vault MySQL Backup And Export Operator role scope ids of where the role is applied e.g Apply MySQL Backup And Export Operator role to the scope of the mysql server"
#   type        = list(string)
#   default     = [] 
# }

# variable "backupvault_postgresql_reader_role_scope_ids" {
#   description = "backup_vault reader role scope ids of where the role is applied e.g ##Apply these reader permissions for the Azure postgresql servers you want to backup"
#   type        = list(string)
#   default     = [""] 
# }

variable "backupvault_keyvaultsecretsuser_role_scope_ids" {
  description = "backup_vault keyvault secrets user role scope ids of where the role is applied e.g ##Apply these permissions on the Azure Key vault that contain the credentials to the Azure postgresql server to allow Azure Backup vault to connect to the database."
  type        = list(string)
  default     = [] 
}

variable "backupvault_storageblobdatacontributor_role_scope_ids" {
  description = "backup_vault storage blob data contributor role scope ids of where the role is applied e.g ##Apply these permissions to the target storage account you want to restore your backup instance files/data to. "
  type        = list(string)
  default     = [] 
}

# variable "backupvault_postgresql_flexible_reader_role_scope_ids" {
#   description = "backup_vault reader role scope ids of where the role is applied e.g ##Apply these reader permissions to the resource group of the Azure postgresql flexible servers you want to backup"
#   type        = list(string)
#   default     = [""] 
# }

variable "backupvault_postgresql_flexible_LTRBackup_scope_ids" {
  description = "backup_vault PostgreSQL Flexible Server Long Term Retention Backup role scope ids of where the role is applied e.g ##Apply these PostgreSQL Flexible Server Long Term Retention Backup to the resource group of the Azure postgresql flexible servers you want to backup"
  type        = list(string)
  default     = [] 
}

# variable "backupvault_postgresql_flexible_storageblobdatacontributor_role_scope_ids" {
#   description = "backup_vault storage blob data contributor role scope ids of where the role is applied e.g ##Apply these permissions to the target storage account you want to restore your postgresql flexible server database/files to."
#   type        = list(string)
#   default     = [""] 
# }

# variable "backupvault_mysql_flexible_storageblobdatacontributor_role_scope_ids" {
#   description = "backup_vault storage blob data contributor role scope ids of where the role is applied e.g ##Apply these permissions to the target storage account you want to restore your mysql flexible server database/files to"
#   type        = list(string)
#   default     = [""] 
# }

# variable "backupvault_kubernetes_reader_role_scope_ids" {
#   description = "backup_vault reader role scope ids of where the role is applied e.g ##Apply these reader permissions to allow backup vault to read kubernetes cluster and read snapshot resource group. "
#   type        = list(string)
#   default     = [""] 
# }

# variable "backupvault_kubernetes_disksnapshotcontributor_role_scope_ids" {
#   description = "backup_vault disk snapshot contributor role scope ids of where the role is applied e.g ##Apply these permissions on kubernetes snapshot resource group"
#   type        = list(string)
#   default     = [""] 
# }

variable "backupvault_datadiskoperator_role_scope_ids" {
  description = "backup_vault data disk operator role scope ids of where the role is applied e.g ##Apply these permissions on kubernetes snapshot resource group"
  type        = list(string)
  default     = [] 
}

# variable "backupvault_kubernetes_storageblobdatacontributor_role_scope_ids" {
#   description = "backup_vault Storage Blob Data Contributor role scope ids of where the role is applied e.g ##Apply these permissions on kubernetes cluster target storage account"
#   type        = list(string)
#   default     = [""] 
# }


