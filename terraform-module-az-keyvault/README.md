# terraform-module-az-keyvault

Terraform module to create an Azure Key Vault, with private endpoint and supporting access policies.

## Module call with required arguments

```hcl
module "keyvault" {
  source                          = "git@github.com:edfenergy/terraform-module-az-keyvault.git?ref=1.5.0"
  resource_group_name             = azurerm_resource_group.main.name
}
```

## Module call with typical optional arguments

```hcl
module "keyvault" {
  source                          = "git@github.com:edfenergy/terraform-module-az-keyvault.git?ref=1.5.0"
  resource_group_name             = azurerm_resource_group.main.name
  company_identifier              = "gen"
  environment                     = "pre"
  enable_private_endpoint         = true
  private_endpoint_subnet_id      = data.azurerm_subnet.pep_subnet.id
  pep_private_dns_rg_id           = var.eit_private_dns_rg_id
  acl_ip_rules                    = var.global_project_ip_ranges
  central_audit_law_workspace_id  = data.azurerm_log_analytics_workspace.cen_audit.workspace_id
  mgmt_law_workspace_id           = data.azurerm_log_analytics_workspace.core_mgmt.workspace_id
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  tags_override                   = merge(var.tags_base, var.tags_keyvault)

  access_policy_for_key_vault_standard_access = {
    spn = var.spns_for_standard_access
    upn = var.upns_for_standard_access
  }
}
```

### Options

#### Key Vault Naming

`company_identifier` - Defaults to "eit" other allowed values are "hub", "cus", "gen", "hpc", "szc".

`environment` - Defaults to "stg" other allowed values are "alz", "prd", "dev", "pre", "tst", "uat".

`data_classification` - Defaults to "hs" other allowed value is "ss".

or

`keyvault_name` - If defined this value will override the default naming conventions using the above option values.

#### Key Vault Access Policy

`access_policy_for_key_vault_standard_access` - Lists of UPNs and SPNs that will be granted standard access to the key vault.

`access_policy_for_key_vault_encryption_at_host_access` - Lists of UPNs and SPNs that will be granted encryption at host access to the key vault.

`disable_default_access_policies` - Disables pipeline SPN access policy defaults to "false" other allowed value is "true".

#### Key Vault using RBAC mode for data operations

`enable_rbac_authorization` - Set this to "true" to use the RBAC authorization model for the key vault. If this is set to true all existing access policies will be cleared and the above access policy variables will be ignored. Defaults to "false".

`key_vault_rbac_access` - Map containing different roles that can be assigned to the keyvault and the respective users and SPNs that are assigned those roles. See the inputs section below on the format to use.

`disable_default_access_policies` - Disables pipeline SPN access policy defaults to "false" other allowed value is "true".

#### Key Vault Private Endpoint

`enable_private_endpoint` - Defaults to "false", other allowed value is "true".

`private_endpoint_subnet_id` - The subnet ID where the private endpoint will be created.

`pep_private_dns_rg_id` - The ID of the resource group where the private DNS zones exist for association with the private endpoint.

`private_endpoint_name` - Overrides the default name for the private endpoint.

`private_service_connection_name` - Overrides the default name for the private service connection.

#### Key Vault ACL Firewall

`public_network_access_enabled` - Defaults to "true", other allowed value is "false".

`acl_default_action` - Default action is "Deny" other allowed action is "Allow".

`acl_ip_rules` - One or more IP addresses or CIDR blocks which should be able to access the Key Vault.

`virtual_network_subnet_ids` - One or more subnet IDs which should be able to access the Key Vault.

#### Key Vault Auditing and Monitoring

`central_audit_law_workspace_id` - Log Analytics Workspace ID for Central Audit

`mgmt_law_workspace_id` - Log Analytics Workspace ID for Management

#### Key Vault Other

`location` - Defaults to "uksouth" other allowed value is "ukwest".

`kv_sku` - Overrides the SKU value which is determined via the enabled_for_disk_encryption option.

`tags_override` - Assigns tags to the taggable resources.

`enabled_for_deployment` - Allows Azure Virtual Machines permission to retrieve certificates stored as secrets from the key vault. Defaults to "false", other allowed value is "true".

`enabled_for_disk_encryption` - Allows Azure Disk Encryption permission to retrieve secrets from the key vault and unwrap keys. Defaults to "false", other allowed value is "true".

`enabled_for_template_deployment` - Allows Azure Resource Manager permission to retrieve secrets from the key vault. Defaults to "false", other allowed value is "true".

`purge_protection_enabled` - Defaults to "true", other allowed value is "false".

`soft_delete_retention_days` - The number of days that items should be retained for once soft deleted. Must be between "7" and "90".

## Code Quality

A number of tests are run against code as part of the GitHub super linter, as such they are not documented here other than links

### Super Linter

- All checks as defined inside the [GitHub super-linter](https://github.com/github/super-linter)

### Conventional commits

Commits to follow [conventional commit](https://www.conventionalcommits.org/en/v1.0.0/) standards.

## Versioning

- Code to be tagged using [SemVer v2.0.0](https://semver.org/) standards.

As below, change x.y.z to the appropriate version increment:

```bash
git tag x.y.z && git push origin x.y.z
```

## Changelog Guide

Refer to below guide to learn how `CHANGELOG.md` gets updated
<https://digitalcentral.edfenergy.com/pages/viewpage.action?pageId=186029053>

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 2.38.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 2.38.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_disk_encryption_set.des](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/disk_encryption_set) | resource |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.azure_backup_access_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.des-id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.encryption_at_host_access_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.pipeline_spn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.standard_access_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_key.key_vault_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_monitor_diagnostic_setting.logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.metrics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.pe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.azure_backup_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.des-id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.key_vault_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.pipeline_spn_access](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.key_vault_backup_operator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azuread_group.group](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_groups.groups_encryption_at_host_access](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/groups) | data source |
| [azuread_groups.groups_standard_access](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/groups) | data source |
| [azuread_service_principal.azure_backup_spn](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azuread_service_principal.spn](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |
| [azuread_service_principals.spns_encryption_at_host_access](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principals) | data source |
| [azuread_service_principals.spns_standard_access](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principals) | data source |
| [azuread_user.user](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |
| [azuread_users.users_upns_encryption_at_host_access](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/users) | data source |
| [azuread_users.users_upns_standard_access](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/users) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_monitor_diagnostic_categories.categories](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policy_for_key_vault_encryption_at_host_access"></a> [access\_policy\_for\_key\_vault\_encryption\_at\_host\_access](#input\_access\_policy\_for\_key\_vault\_encryption\_at\_host\_access) | [OPTIONAL] Lists of UPNs and SPNs that will be granted encryption at host access to the key vault.  upn, spn, or group need to be the object name, and require Entra read access to the object. | <pre>object({<br>    upn   = optional(list(string), [])<br>    spn   = optional(list(string), [])<br>    group = optional(list(string), [])<br>    oids  = optional(list(string), [])<br>  })</pre> | `{}` | no |
| <a name="input_access_policy_for_key_vault_standard_access"></a> [access\_policy\_for\_key\_vault\_standard\_access](#input\_access\_policy\_for\_key\_vault\_standard\_access) | [OPTIONAL] Lists of UPNs and SPNs that will be granted standard access to the key vault. upn, spn, or group need to be the object name, and require Entra read access to the object. | <pre>object({<br>    upn   = optional(list(string), [])<br>    spn   = optional(list(string), [])<br>    group = optional(list(string), [])<br>    oids  = optional(list(string), [])<br>  })</pre> | `{}` | no |
| <a name="input_acl_default_action"></a> [acl\_default\_action](#input\_acl\_default\_action) | [OPTIONAL] Default action for Network ACL, must be set to Allow or Deny. | `string` | `"Deny"` | no |
| <a name="input_acl_ip_rules"></a> [acl\_ip\_rules](#input\_acl\_ip\_rules) | [OPTIONAL] One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault. | `list(string)` | `[]` | no |
| <a name="input_central_audit_law_workspace_id"></a> [central\_audit\_law\_workspace\_id](#input\_central\_audit\_law\_workspace\_id) | [OPTIONAL] Log Analytics Workspace ID for Central Audit. | `string` | `null` | no |
| <a name="input_company_identifier"></a> [company\_identifier](#input\_company\_identifier) | [OPTIONAL] Company identifier. | `string` | `"eit"` | no |
| <a name="input_data_classification"></a> [data\_classification](#input\_data\_classification) | [OPTIONAL] Data classification level. | `string` | `"hs"` | no |
| <a name="input_disable_default_access_policies"></a> [disable\_default\_access\_policies](#input\_disable\_default\_access\_policies) | [OPTIONAL] Switch to disable default access policies. | `bool` | `false` | no |
| <a name="input_disk_encryption_set"></a> [disk\_encryption\_set](#input\_disk\_encryption\_set) | A map of Disk Encryption Set (DES). The map Key is used for the name of the DES | <pre>map(object({<br>    resource_group_name = optional(string, null)<br>  }))</pre> | `{}` | no |
| <a name="input_enable_encryption_at_host"></a> [enable\_encryption\_at\_host](#input\_enable\_encryption\_at\_host) | [OPTIONAL] Used to enable Encryption at Host. Which creates a 'premium' SKU type. | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | [OPTIONAL] Whether to set up a private endpoint and allow Key Vault access only from the endpoint. | `bool` | `false` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | (Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions. | `bool` | `false` | no |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | [OPTIONAL] Can Azure Virtual Machines retrieve certificates stored as secrets from the Key Vault? | `bool` | `false` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | [OPTIONAL] Used to enable Azure Disk Encryption. Which creates a 'premium' SKU type. | `bool` | `false` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | [OPTIONAL] Can Azure Resource Manager retrieve secrets from the key Vault? | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | [OPTIONAL] The name of the environment | `string` | `"stg"` | no |
| <a name="input_key_vault_rbac_access"></a> [key\_vault\_rbac\_access](#input\_key\_vault\_rbac\_access) | [OPTIONAL] Lists of SPNs and users that will be granted access to the key vault via Azure RBAC for the roles found at [Azure built-in roles for Key Vault data plane operations.](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide#azure-built-in-roles-for-key-vault-data-plane-operations) | <pre>object({<br>    key_vault_administrator = optional(object({<br>      spns   = optional(list(string), [])<br>      users  = optional(list(string), [])<br>      groups = optional(list(string), [])<br>    }), {})<br>    key_vault_reader = optional(object({<br>      spns   = optional(list(string), [])<br>      users  = optional(list(string), [])<br>      groups = optional(list(string), [])<br>    }), {})<br>    key_vault_purge_operator = optional(object({<br>      spns   = optional(list(string), [])<br>      users  = optional(list(string), [])<br>      groups = optional(list(string), [])<br>    }), {})<br>    key_vault_certificates_officer = optional(object({<br>      spns   = optional(list(string), [])<br>      users  = optional(list(string), [])<br>      groups = optional(list(string), [])<br>    }), {})<br>    key_vault_certificate_user = optional(object({<br>      spns   = optional(list(string), [])<br>      users  = optional(list(string), [])<br>      groups = optional(list(string), [])<br>    }), {})<br>    key_vault_crypto_officer = optional(object({<br>      spns   = optional(list(string), [])<br>      users  = optional(list(string), [])<br>      groups = optional(list(string), [])<br>    }), {})<br>    key_vault_crypto_service_encryption_user = optional(object({<br>      spns   = optional(list(string), [])<br>      users  = optional(list(string), [])<br>      groups = optional(list(string), [])<br>    }), {})<br>    key_vault_crypto_user = optional(object({<br>      spns   = optional(list(string), [])<br>      users  = optional(list(string), [])<br>      groups = optional(list(string), [])<br>    }), {})<br>    key_vault_crypto_service_release_user = optional(object({<br>      spns   = optional(list(string), [])<br>      users  = optional(list(string), [])<br>      groups = optional(list(string), [])<br>    }), {})<br>    key_vault_secrets_officer = optional(object({<br>      spns   = optional(list(string), [])<br>      users  = optional(list(string), [])<br>      groups = optional(list(string), [])<br>    }), {})<br>    key_vault_secrets_user = optional(object({<br>      spns   = optional(list(string), [])<br>      users  = optional(list(string), [])<br>      groups = optional(list(string), [])<br>    }), {})<br>  })</pre> | `{}` | no |
| <a name="input_keyvault_name"></a> [keyvault\_name](#input\_keyvault\_name) | [OPTIONAL] Name of the Keyvault | `string` | `null` | no |
| <a name="input_kv_sku"></a> [kv\_sku](#input\_kv\_sku) | [OPTIONAL] Optionally override the SKU for the Key Vault when using Azure Disk Encryption. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | [OPTIONAL] Provide location to deploy azure pipeline resources | `string` | `"uksouth"` | no |
| <a name="input_mgmt_law_workspace_id"></a> [mgmt\_law\_workspace\_id](#input\_mgmt\_law\_workspace\_id) | [OPTIONAL] Log Analytics Workspace ID for Management. | `string` | `null` | no |
| <a name="input_pep_private_dns_rg_id"></a> [pep\_private\_dns\_rg\_id](#input\_pep\_private\_dns\_rg\_id) | [OPTIONAL] ID of the resource group where the private DNS zones exist for association with the private endpoints. | `string` | `null` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | [OPTIONAL] Specifies a custom name for the private endpoint, mainly used for dealing with existing resources. | `string` | `null` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | [OPTIONAL] The subnet ID where the private endpoints will be created. | `string` | `null` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | [OPTIONAL] Specifies a custom name for the private service connection, mainly used for dealing with existing resources. | `string` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | [OPTIONAL] Whether public network access is allowed for this Key Vault. Defaults to true. | `bool` | `true` | no |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | [OPTIONAL] Is Purge Protection enabled for this Key Vault? | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | [OPTIONAL] The number of days that items should be retained for once soft deleted. Must be between 7 and 90. | `number` | `90` | no |
| <a name="input_tags_override"></a> [tags\_override](#input\_tags\_override) | [OPTIONAL] Common Tags for Azure Resources | `map(string)` | `{}` | no |
| <a name="input_virtual_network_subnet_ids"></a> [virtual\_network\_subnet\_ids](#input\_virtual\_network\_subnet\_ids) | [OPTIONAL] One or more Subnets which should be able to access the Key Vault. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_des_ids"></a> [des\_ids](#output\_des\_ids) | n/a |
| <a name="output_des_principal_ids"></a> [des\_principal\_ids](#output\_des\_principal\_ids) | n/a |
| <a name="output_keyvault"></a> [keyvault](#output\_keyvault) | keyvault |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
