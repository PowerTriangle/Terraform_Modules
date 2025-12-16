# terraform-module-az-backup-vault

Terraform Module to create an Azure Backup Vault which includes support for managing backup policies and backup instances associated with the Azure Backup Vault. The Azure Backup Vault Module supports the management of disks, kubernetes Clusters, Azure Blobs, Postgresql Servers, Postgresql flexible servers and mysql flexible servers backups.

## Module call

```text
module "backupvault" {
  source                                      = "./modules/backupvault"
  backup_vault_name           = "test1"
  backup_vault_location                       = "UK South"
  backup_vault_resource_group_name =   azurerm_resource_group.rg.name
  backup_vault_datastore_type                 = "VaultStore"
  backup_vault_redundancy                     = "LocallyRedundant"
  backup_vault_soft_delete       = "Off"
  backupvault_disk_snapshot_contributor_role_scope_ids = ["${azurerm_resource_group.rg.id}"]
  backupvault_disk_restore_operator_role_scope_ids = ["${azurerm_resource_group.rg.id}"]
  backupvault_disk_backup_reader_role_scope_ids = ["${azurerm_resource_group.rg.id}"]
  backupvault_storage_account_backup_contributor_role_scope_ids = ["${azurerm_resource_group.rg.id}"]
  backupvault_reader_role_scope_ids = ["${azurerm_resource_group.rg.id}"]
  backupvault_postgresql_flexible_LTRBackup_scope_ids = ["${azurerm_resource_group.rg.id}"]
  backupvault_storageblobdatacontributor_role_scope_ids = ["${azurerm_resource_group.rg.id}"]
  backupvault_datadiskoperator_role_scope_ids = ["${azurerm_resource_group.rg.id}"]
  backupvault_keyvaultsecretsuser_role_scope_ids = ["${azurerm_resource_group.rg.id}"]
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
      snapshot_resource_group_name = azurerm_resource_group.rg.name
       backup_policy_id = module.backupvault.backup_policy_disk_id[0]
    }
  }
  kubernetes_backup_instances = {
    kubernetes1 = {
      name = "test2"
      location = "UK South"
      snapshot_resource_group_name = azurerm_resource_group.rg.name
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
      resource_group_name = "${azurerm_resource_group.rg.name}"
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
      resource_group_name = "${azurerm_resource_group.rg.name}"
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
  depends_on = [azurerm_managed_disk.example, azurerm_storage_account.example, azurerm_kubernetes_cluster.example, azurerm_postgresql_flexible_server.example, azurerm_postgresql_server.example, azurerm_postgresql_database.example, azurerm_postgresql_firewall_rule.example]
}
```

## Azure Backup Vault Azure RBAC permissions

Azure Backup Vault has a system-assigned managed identity.
Depending on what type of backup you use backup vault for, you will need to grant certain Azure RBAC permissions to the backup vault identity to enable it to perform the backup and restore process when required.

For Disk Backups

Assign the Disk Backup Reader role to Backup Vault’s managed identity on the Source disk that needs to be backed up.
This can be done using the module variable backupvault_disk_snapshot_contributor_role_scope_ids.

Assign the Disk Snapshot Contributor role to the Backup vault’s managed identity on the Resource group where backups are created and managed by the Azure Backup service. The disk snapshots are stored in a resource group within your subscription. To allow Azure Backup service to create, store, and manage snapshots, you need to provide permissions to the backup vault.
This can be done using the module variable backupvault_disk_snapshot_contributor_role_scope_ids.

To Restore Disk from backup

Assign the Disk Restore Operator role to the Backup Vault’s managed identity on the Resource group where the disk will be restored by the Azure Backup service.
This can be done using the module variable backupvault_disk_restore_operator_role_scope_ids.

Source:
<https://learn.microsoft.com/en-us/azure/backup/backup-managed-disks>
<https://learn.microsoft.com/en-us/azure/backup/restore-managed-disks>

For Azure Blob Backups

Assign the Storage account backup contributor role to the backup vault identity for the required storage accounts that need to be backed up and/or backup data to be restored to.
This can be done using the module variable backupvault_storage_account_backup_contributor_role_scope_ids.

source:
<https://learn.microsoft.com/en-us/azure/backup/blob-backup-configure-manage?tabs=operational-backup>
<https://learn.microsoft.com/en-us/azure/backup/blob-restore?tabs=operational-backup>

For Postgresql Backups

Grant the following access permissions to the Backup vault’s Managed System Identity:

Reader access on the Azure PostgreSQL server.
This can be done using the module variable backupvault_disk_backup_reader_role_scope_ids.

Key Vault Secrets User (or get, list secrets) access on the Azure key vault.
This can be done using the module variable backupvault_keyvaultsecretsuser_role_scope_ids.

To restore the postgresql data you will need to assign the backup vault managed identity
the Storage Blob Data Contributor role to the target storage account you want to restore your data to.
This can be done using the module variable backupvault_storageblobdatacontributor_role_scope_ids.

source:
<https://learn.microsoft.com/en-us/azure/backup/backup-azure-database-postgresql-overview>
<https://learn.microsoft.com/en-us/azure/backup/restore-azure-database-postgresql>

For Kubernetes Cluster Backups

For Assigning permissions to the backup vault managed system identity:

Assign Reader role to the AKS Cluster you want to backup and snapshot resource group.
This can be done using the module variable backupvault_disk_backup_reader_role_scope_ids.

Assign Disk Snapshot Contributor role to the snapshot resource group to store your kubernetes data.
This can be done using the module variable backupvault_disk_snapshot_contributor_role_scope_ids.

Assign Data Operator for Managed Disks role to the snapshot resource group.
This can be done using the module variable backupvault_datadiskoperator_role_scope_ids

Assign Storage Blob Data Contributor role to the target storage account you want to restore your kubernetes data to.
This can be done using the module variable backupvault_storageblobdatacontributor_role_scope_ids.

Source:
<https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_kubernetes_cluster>
<https://learn.microsoft.com/en-us/azure/backup/quick-kubernetes-backup-terraform>

For Postgresql flexible server backups

For Assigning permissions to the backup vault managed system identity:

Backup:

PostgreSQL Flexible Server Long Term Retention Backup role on the server.
This can be done using the module variable backupvault_postgresql_flexible_LTRBackup_scope_ids

Reader role on the resource group of the server.
This can be done using the module variable backupvault_disk_backup_reader_role_scope_ids.

Restore:

Storage Blob Data Contributor role on the target storage account.
This can be done using the module variable backupvault_storageblobdatacontributor_role_scope_ids.

source:
<https://learn.microsoft.com/en-us/azure/backup/backup-azure-database-postgresql-flex-overview>

For Mysql flexible server backups

For Assigning permissions to the backup vault managed system identity:

Backup:

MySQL Backup And Export Operator role on the server.
This can be done using the module variable backupvault_MySQL_Backup_And_Export_Operator_role_scope_ids.

Reader role on the resource group of the server.
This can be done using the module variable backupvault_disk_backup_reader_role_scope_ids.

Restore:

Storage Blob Data Contributor role on the target storage account.
This can be done using the module variable backupvault_storageblobdatacontributor_role_scope_ids.

source:
<https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_mysql_flexible_server>
<https://learn.microsoft.com/en-us/azure/backup/backup-azure-mysql-flexible-server-restore>

## Versioning

- Code to be tagged using [SemVer v2.0.0](https://semver.org/) standards.

As below, change x.y.z to the appropriate version increment:

```bash
git tag x.y.z && git push origin x.y.z
```

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >=1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | < 4.0.0 |

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | < 4.0.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                                                             | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [azurerm_data_protection_backup_vault.backup_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault)                                                                | resource |
| [azurerm_data_protection_backup_policy_disk.backup_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_disk)                                                   | resource |
| [azurerm_data_protection_backup_policy_blob_storage.backup_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_blob_storage)                                   | resource |
| [azurerm_data_protection_backup_policy_kubernetes_cluster.backup_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_kubernetes_cluster)                       | resource |
| [azurerm_data_protection_backup_policy_postgresql.backup_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_postgresql)                                       | resource |
| [azurerm_data_protection_backup_policy_postgresql_flexible_server.backup_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_postgresql_flexible_server)       | resource |
| [azurerm_data_protection_backup_instance_disk.backup_instance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk)                                             | resource |
| [azurerm_data_protection_backup_instance_blob_storage.backup_instance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_blob_storage)                             | resource |
| [azurerm_data_protection_backup_instance_kubernetes_cluster.backup_instance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_kubernetes_cluster)                 | resource |
| [azurerm_data_protection_backup_instance_postgresql.backup_instance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_postgresql)                                 | resource |
| [azurerm_data_protection_backup_instance_postgresql_flexible_server.backup_instance](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_postgresql_flexible_server) | resource |
| [azurerm_role_assignment.backupvault_disk_snapshot_contributor_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                            | resource |
| [azurerm_role_assignment.backupvault_disk_reader_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                                          | resource |
| [azurerm_role_assignment.backupvault_disk_restore_operator_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                                | resource |
| [azurerm_role_assignment.backupvault_storage_account_backup_contributor_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                   | resource |
| [azurerm_role_assignment.backupvault_reader_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                                               | resource |
| [azurerm_role_assignment.backupvault_storageblobdatacontributor_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                           | resource |
| [azurerm_role_assignment.backupvault_keyvaultsecretsuser_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                                  | resource |
| [azurerm_role_assignment.backupvault_postgresql_flexible_LTRBackup_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                        | resource |
| [azurerm_role_assignment.backupvault_datadiskoperator_role](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                                                                     | resource |

## Inputs

| Name                                                                                                                                                                                                                     | Description                                                                                                                                                                                                                                                            | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Default      | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | :------: |
| <a name="input_disk_backup_policies"></a> [disk_backup_policies](#input_disk_backup_policies)                                                                                                                            | Manages Disk Backup Policies.                                                                                                                                                                                                                                          | <pre>map(object({<br> name = string<br> backup_repeating_time_intervals = list(string)<br> default_retention_duration = string<br> retention_rules = optional(map(object({<br> name = string<br> priority = number<br> duration = string<br> criteria = object({<br> absolute_criteria = optional(string)<br> })<br> })))<br> timezone = optional(string)<br> enable_retention_rules = bool<br> }))</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                | `{}`         |    no    |
| <a name="input_blob_backup_policies"></a> [blob_backup_policies](#input_blob_backup_policies)                                                                                                                            | Manages Blob Storage Backup Policies                                                                                                                                                                                                                                   | <pre>map(object({<br> name = string<br> operational_default_retention_duration = optional(string)<br> backup_repeating_time_intervals = optional(list(string))<br> vault_default_retention_duration = optional(string)<br> retention_rules = optional(map(object({<br> name = string<br> priority = number<br> duration = string<br> life_cycle = object({<br> duration = string<br> data_store_type = string<br> })<br> criteria = object({<br> absolute_criteria = optional(string)<br> days_of_month = optional(set(number))<br> days_of_week = optional(set(string))<br> months_of_year = optional(set(string))<br> weeks_of_month = optional(set(string))<br> scheduled_backup_times = optional(list(string))<br> })<br> })))<br> timezone = optional(string)<br> enable_retention_rules = bool<br> }))</pre>                       | `{}`         |    no    |
| <a name="input_kubernetes_backup_policies"></a> [kubernetes_backup_policies](#input_kubernetes_backup_policies)                                                                                                          | Manages kubernetes Backup Policies                                                                                                                                                                                                                                     | <pre>map(object({<br> name = string<br> resource_group_name = string<br> backup_repeating_time_intervals = optional(list(string))<br> default_retention_rule = object({<br> life_cycle = object({<br> data_store_type = string<br> duration = string<br> })<br> })<br> retention_rules = optional(map(object({<br> name = string<br> priority = number<br> life_cycle = object({<br> duration = string<br> data_store_type = string<br> })<br> criteria = object({<br> absolute_criteria = optional(string)<br> days_of_month = optional(set(number))<br> days_of_week = optional(set(string))<br> months_of_year = optional(set(string))<br> weeks_of_month = optional(set(string))<br> scheduled_backup_times = optional(list(string))<br> })<br> })))<br> timezone = optional(string)<br> enable_retention_rules = bool<br> }))</pre> | `{}`         |    no    |
| <a name="input_postgresql_flexible_backup_policies"></a> [postgresql_flexible_backup_policies](#input_postgresql_flexible_backup_policies)                                                                               | Manages Postgresql Flexible Server Backup Policies                                                                                                                                                                                                                     | <pre>map(object({<br> name = string<br> backup_repeating_time_intervals = optional(list(string))<br> default_retention_rule = object({<br> life_cycle = object({<br> data_store_type = string<br> duration = string<br> })<br> })<br> retention_rules = optional(map(object({<br> name = string<br> priority = number<br> life_cycle = object({<br> duration = string<br> data_store_type = string<br> })<br> criteria = object({<br> absolute_criteria = optional(string)<br> days_of_week = optional(set(string))<br> months_of_year = optional(set(string))<br> weeks_of_month = optional(set(string))<br> scheduled_backup_times = optional(list(string))<br> })<br> })))<br> timezone = optional(string)<br> enable_retention_rules = bool<br> }))</pre>                                                                            | `{}`         |    no    |
| <a name="input_postgresql_backup_policies"></a> [postgresql_backup_policies](#input_postgresql_backup_policies)                                                                                                          | Manages Postgresql Backup Policies                                                                                                                                                                                                                                     | <pre>map(object({<br> name = string<br> resource_group_name = string<br> backup_repeating_time_intervals = optional(list(string))<br> default_retention_duration = string<br> retention_rules = optional(map(object({<br> name = string<br> priority = number<br> life_cycle = object({<br> duration = string<br> data_store_type = string<br> })<br> criteria = object({<br> absolute_criteria = optional(string)<br> days_of_week = optional(set(string))<br> months_of_year = optional(set(string))<br> weeks_of_month = optional(set(string))<br> scheduled_backup_times = optional(list(string))<br> })<br> })))<br> timezone = optional(string)<br> enable_retention_rules = bool<br> }))</pre>                                                                                                                                    | `{}`         |    no    |
| <a name="input_disks_backup_instances"></a> [disks_backup_instances](#input_disks_backup_instances)                                                                                                                      | Manages Disk Backup Instances                                                                                                                                                                                                                                          | <pre>map(object({<br> name = string<br> location = string<br> disk_id = string<br> snapshot_resource_group_name = string<br> backup_policy_id = string<br> }))</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | `{}`         |    no    |
| <a name="input_azure_blobs_backup_instances"></a> [azure_blobs_backup_instances](#input_azure_blobs_backup_instances)                                                                                                    | Manages Azure Blob Storage Backup Instances                                                                                                                                                                                                                            | <pre>map(object({<br> name = string<br> location = string<br> storage_account_id = string<br> storage_account_container_names = optional(list(string))<br> backup_policy_id = string<br> }))</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | `{}`         |    no    |
| <a name="input_kubernetes_backup_instances"></a> [kubernetes_backup_instances](#input_kubernetes_backup_instances)                                                                                                       | Manages Kubernetes Backup Instances                                                                                                                                                                                                                                    | <pre>map(object({<br> name = string<br> location = string<br> kubernetes_cluster_id = string<br> snapshot_resource_group_name = string<br> backup_policy_id = string<br> backup_datasource_parameters = optional(object({<br> excluded_namespaces = optional(list(string))<br> excluded_resource_types = optional(list(string))<br> cluster_scoped_resources_enabled = optional(bool, false)<br> included_namespaces = optional(list(string))<br> included_resource_types = optional(list(string))<br> label_selectors = optional(list(string))<br> volume_snapshot_enabled = optional(bool, false)<br> }))<br> }))</pre>                                                                                                                                                                                                                | `{}`         |    no    |
| <a name="input_postgresql_backup_instances"></a> [postgresql_backup_instances](#input_postgresql_backup_instances)                                                                                                       | Manages Postgresql Backup Instances                                                                                                                                                                                                                                    | <pre>map(object({<br> name = string<br> location = string<br> database_id = string<br> database_credential_key_vault_secret_id = optional(string)<br> backup_policy_id = string<br> }))</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | `{}`         |    no    |
| <a name="input_postgresql_flexible_backup_instances"></a> [postgresql_flexible_backup_instances](#input_postgresql_flexible_backup_instances)                                                                            | Manages Postgresql Flexible Server Backup Instances                                                                                                                                                                                                                    | <pre>map(object({<br> name = string<br> location = string<br> server_id = string<br> backup_policy_id = string<br> }))</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | `{}`         |    no    |
| <a name="input_backup_vault_location"></a> [backup_vault_location](#input_backup_vault_location)                                                                                                                         | Azure region of azure backup vault                                                                                                                                                                                                                                     | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | `"UK South"` |   yes    |
| <a name="input_backup_vault_name"></a> [backup_vault_name](#input_backup_vault_name)                                                                                                                                     | name of azure backup vault                                                                                                                                                                                                                                             | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ``           |   yes    |
| <a name="input_backup_vault_redundancy"></a> [backup_vault_redundancy](#input_backup_vault_redundancy)                                                                                                                   | redundancy of azure backup vault                                                                                                                                                                                                                                       | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ``           |   yes    |
| <a name="input_backup_vault_retention_duration_in_days"></a> [backup_vault_retention_duration_in_days](#input_backup_vault_retention_duration_in_days)                                                                   | the number of days for which deleted data is retained before being permanently deleted                                                                                                                                                                                 | `number`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | `14`         |    no    |
| <a name="input_backup_vault_soft_delete"></a> [backup_vault_soft_delete](#input_backup_vault_soft_delete)                                                                                                                | The state of soft delete for this Backup Vaul                                                                                                                                                                                                                          | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | `On`         |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                                                                                                            | A mapping of tags which should be assigned to the Backup Vault.                                                                                                                                                                                                        | `map(any)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `{}`         |   yes    |
| <a name="input_backup_vault_datastore_type"></a> [backup_vault_datastore_type](#input_backup_vault_datastore_type)                                                                                                       | backup_vault_datastore_type                                                                                                                                                                                                                                            | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | `VaultStore` |    no    |
| <a name="input_backup_vault_resource_group_name"></a> [backup_vault_resource_group_name](#input_backup_vault_resource_group_name)                                                                                        | azure backup vault resource group name                                                                                                                                                                                                                                 | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | ``           |   yes    |
| <a name="input_backupvault_disk_snapshot_contributor_role_scope_ids"></a> [backupvault_disk_snapshot_contributor_role_scope_ids](#input_backupvault_disk_snapshot_contributor_role_scope_ids)                            | backup_vault disk snapshot contributor role scope ids of where the role is applied e.g resource group ids where disk snapshots made from backupvault can be stored                                                                                                     | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `[]`         |    no    |
| <a name="input_backupvault_disk_backup_reader_role_scope_ids"></a> [backupvault_disk_backup_reader_role_scope_ids](#input_backupvault_disk_backup_reader_role_scope_ids)                                                 | backup_vault disk backup reader role scope ids of where the role is applied e.g disks ids to allow backup vault to read disks to enable disk backups                                                                                                                   | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `[]`         |    no    |
| <a name="input_backupvault_disk_restore_operator_role_scope_ids"></a> [backupvault_disk_restore_operator_role_scope_ids](#input_backupvault_disk_restore_operator_role_scope_ids)                                        | backup_vault disk restore operator role scope ids of where the role is applied e.g resource group ids where disk snapshots can be restored to disks                                                                                                                    | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `[]`         |    no    |
| <a name="input_backupvault_storage_account_backup_contributor_role_scope_ids"></a> [backupvault_storage_account_backup_contributor_role_scope_ids](#input_backupvault_storage_account_backup_contributor_role_scope_ids) | backup_vault storage account backup contributor role scope ids of where the role is applied e.g Storage account containing the blob you want to backup and restore to                                                                                                  | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `[]`         |    no    |
| <a name="input_backupvault_reader_role_scope_ids"></a> [backupvault_reader_role_scope_ids](#input_backupvault_reader_role_scope_ids)                                                                                     | backup_vault reader role scope ids of where the role is applied e.g Apply reader role to the resource group of instances you want to backup                                                                                                                            | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `[]`         |    no    |
| <a name="input_backupvault_keyvaultsecretsuser_role_scope_ids"></a> [backupvault_keyvaultsecretsuser_role_scope_ids](#input_backupvault_keyvaultsecretsuser_role_scope_ids)                                              | backup_vault keyvault secrets user role scope ids of where the role is applied e.g Apply these permissions on the Azure Key vault that contain the credentials to the Azure postgresql server to allow Azure Backup vault to connect to the database.                  | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `[]`         |    no    |
| <a name="input_backupvault_storageblobdatacontributor_role_scope_ids"></a> [backupvault_storageblobdatacontributor_role_scope_ids](#input_backupvault_storageblobdatacontributor_role_scope_ids)                         | backup_vault storage blob data contributor role scope ids of where the role is applied e.g Apply these permissions to the target storage account you want to restore your backup instance files/data to.                                                               | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `[]`         |    no    |
| <a name="input_backupvault_postgresql_flexible_LTRBackup_scope_ids"></a> [backupvault_postgresql_flexible_LTRBackup_scope_ids](#input_backupvault_postgresql_flexible_LTRBackup_scope_ids)                               | backup_vault PostgreSQL Flexible Server Long Term Retention Backup role scope ids of where the role is applied e.g Apply these PostgreSQL Flexible Server Long Term Retention Backup to the resource group of the Azure postgresql flexible servers you want to backup | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `[]`         |    no    |
| <a name="input_backupvault_datadiskoperator_role_scope_ids"></a> [backupvault_datadiskoperator_role_scope_ids](#input_backupvault_datadiskoperator_role_scope_ids)                                                       | backup_vault data disk operator role scope ids of where the role is applied e.g Apply these permissions on kubernetes snapshot resource group                                                                                                                          | `list(string)`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `[]`         |    no    |
| <a name="input_backup_vault_cross_region_restore_enabled"></a> [backup_vault_cross_region_restore_enabled](#input_backup_vault_cross_region_restore_enabled)                                                       | Whether to enable cross-region restore for the Backup Vault, can only be specified when redundancy is GeoRedundant                                                                                                                          | `bool`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `false`         |    no    |
| <a name="input_backup_vault_immutability"></a> [backup_vault_backup_vault_immutability](#input_backup_vault_backup_vault_immutability)                                                       | The state of immutability for this Backup Vault                                                                                                                          | `string`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | `Disabled`         |    no    |

## Outputs

| Name                                                                                                                                                                    | Description                                           | Output Usage                                                                     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- | -------------------------------------------------------------------------------- |
| <a name="output_backup_vault_id"></a> [backup_vault_id](#output_backup_vault_id)                                                                                        | The ID of the Azure Backup Vault                      | "module.<module_name>.backup_vault_id"                                           |
| <a name="output_backup_vault_identity"></a> [backup_vault_identity](#output_backup_vault_identity)                                                                      | The system identity of the Azure Backup Vault         | "module.<module_name>.backup_vault_identity"                                     |
| <a name="output_backup_policy_disk_id"></a> [backup_policy_disk_id](#output_backup_policy_disk_id)                                                                      | The ID of disk backup policies                        | "module.<module_name>.backup_policy_disk_id[index e.g 0]"                        |
| <a name="output_backup_policy_blob_storage_id"></a> [backup_policy_blob_storage_id](#output_backup_policy_blob_storage_id)                                              | The ID of blob storage backup policies                | "module.<module_name>.backup_policy_blob_storage_id[index e.g 0]"                |
| <a name="output_backup_policy_kubernetes_id"></a> [backup_policy_kubernetes_id](#output_backup_policy_kubernetes_id)                                                    | The ID of Kubernetes backup policies                  | "module.<module_name>.backup_policy_kubernetes_id[index e.g 0]"                  |
| <a name="output_backup_policy_postgresql_flexible_id"></a> [backup_policy_postgresql_flexible_id](#output_backup_policy_postgresql_flexible_id)                         | The ID of postgresql flexible server backup policies  | "module.<module_name>.backup_policy_postgresql_flexible_id[index e.g 0]"         |
| <a name="output_backup_policy_postgresql_id"></a> [backup_policy_postgresql_id](#output_backup_policy_postgresql_id)                                                    | The ID of postgresql backup policies                  | "module.<module_name>.backup_policy_postgresql_id[index e.g 0]"                  |
| <a name="output_backup_vault_instance_disk_id"></a> [backup_vault_instance_disk_id](#output_backup_vault_instance_disk_id)                                              | The ID of disk backup instances                       | "module.<module_name>.backup_vault_instance_disk_id[index e.g 0]"                |
| <a name="output_backup_vault_instance_blob_storage_id"></a> [backup_vault_instance_blob_storage_id](#output_backup_vault_instance_blob_storage_id)                      | The ID of blob storage backup instances               | "module.<module_name>.backup_vault_instance_blob_storage_id[index e.g 0]"        |
| <a name="output_backup_vault_instance_kubernetes_id"></a> [backup_vault_instance_kubernetes_id](#output_backup_vault_instance_kubernetes_id)                            | The ID of kubernetes backup instances                 | "module.<module_name>.backup_vault_instance_kubernetes_id[index e.g 0]"          |
| <a name="output_backup_vault_instance_postgresql_id"></a> [backup_vault_instance_postgresql_id](#output_backup_vault_instance_postgresql_id)                            | The ID of postgresql backup instances                 | "module.<module_name>.backup_vault_instance_postgresql_id[index e.g 0]"          |
| <a name="output_backup_vault_instance_postgresql_flexible_id"></a> [backup_vault_instance_postgresql_flexible_id](#output_backup_vault_instance_postgresql_flexible_id) | The ID of postgresql flexible server backup instances | "module.<module_name>.backup_vault_instance_postgresql_flexible_id[index e.g 0]" |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
