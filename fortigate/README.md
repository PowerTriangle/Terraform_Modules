# terraform-module-az-firewall-fortigate

Terraform module to create FortiGate Virtual Machine in EDF Transit Hub virtual network. It supports FortiGate Azure images with configured NIC, managed osdisk, managed data disk etc. Module will build a Virtual Machine from a specified Fortinet Fortigate Azure Marketplace image and loading basic Fortigate bootstrap configuration using custom data. Licensed types available: PAYG and BYOL (token or license file options).
Disks' backups are designed to be deployed using separate backup vault module.

Default settings:

- PAYG licensing
- Credentials (random password) created and stored in Key Vault
- Disabled encryption at host
- Standard security type
- Storage Account type: "Premium_LRS"
- OS disk size defined by FortiGate image size
- VM size: "Standard_F8s_v2"
- Image: publisher: "fortinet", offer: "fortinet_fortigate-vm_v5", sku: "fortinet_fg-vm_payg_2023", version: "7.0.14"
- Configuration bootstrap file loaded as custom data and prepared using template_file

## Module call

```text
module "t1_vm_example" {
  source                       = "./modules/terraform-module-az-firewall-fortigate"
  for_each                     = var.t1_firewalls
  resource_group_location      = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  license_type                 = var.t1_license_type
  accept_marketplace_agreement = false
  fgtvm_custom_data            = data.template_file.t1_init_cfg[each.key].rendered  # locals.custom_data
  subscription_env_config = {
    boot_diagnostics_storage_uri = module.storage_account["vm_logs"].storage_account.primary_blob_endpoint
    keyvault_id                  = module.gp_key_vault.keyvault.id
    vnet_id                      = module.vnet.virtual_network_id
  }
  availability_zone = each.value.zone
  vm_osdisk_size_gb = null
  vm_name           = "lab11-t1fw${each.key}"
  nics = {
    "00-eituksalzt1fw${each.key}" = {
      name                          = "eituksalzt1fw${each.key}-ext-nic-01"
      enable_accelerated_networking = true
      enable_ip_forwarding          = true
      ip_configurations = {
        "ipconfig1" = {
          private_ip_address_allocation = "Static"
          private_ip_address            = each.value.t1nic-ext_ipaddr
          subnet_id                     = module.vnet.subnet_ids["eit-alz-t1ext-snet-01"]
        }
      }
    }
    "01-eituksalzt1fw${each.key}" = {
      name                          = "eituksalzt1fw${each.key}-int-nic-01"
      enable_accelerated_networking = true
      enable_ip_forwarding          = true
      ip_configurations = {
        "ipconfig1" = {
          private_ip_address_allocation = "Static"
          private_ip_address            = each.value.t1nic-int_ipaddr
          subnet_id                     = module.vnet.subnet_ids["eit-alz-t1int-snet-01"]
        }
      }
    }
    "02-eituksalzt1fw${each.key}" = {
      name = "eituksalzt1fw${each.key}-hasync-nic-01"
      ip_configurations = {
        "ipconfig1" = {
          private_ip_address_allocation = "Static"
          private_ip_address            = each.value.t1nic-hasync_ipaddr
          subnet_id                     = module.vnet.subnet_ids["eit-alz-t1hasync-snet-01"]
        }
      }
    }
    "03-eituksalzt1fw${each.key}" = {
      name = "eituksalzt1fw${each.key}-mgmt-nic-01"
      ip_configurations = {
        "ipconfig1" = {
          private_ip_address_allocation = "Static"
          private_ip_address            = each.value.t1nic-mgmt_ipaddr
          subnet_id                     = module.vnet.subnet_ids["eit-alz-t1mgmt-snet-01"]
        }
      }
    }
  }
  data_disks = {
    "01" = {
      name = "${each.key}-datadisk-01"
      source = "new"
      size   = "30"
      class  = "Premium_LRS"
   }
  }
  tags = {
    "Name"            = "${each.key}",
    "Business Unit"   = "corporate",
    "Category"        = "infrastructure",
    "Cost Centre"     = "tabb",
    "Owner"           = "cloudservices@edfenergy.com",
    "Role"            = "t1_firewall",
    "Service"         = "network",
    "Service Level"   = "gold",
    "Support"         = "azure landing zone ss platform team",
    "am support team" = "eis secops",
    "environment"     = "production"
    "BackupPolicy"    = "backup_policy_01"
  }
}

data "template_file" "t1_init_cfg" {
  for_each = var.t1_firewalls
  template = file("${path.module}/templates/t1${each.key}_conf_bootstrap.tftpl")
  vars = {
    type            = var.t1_license_type
    license_file    = var.t1_license_file["t1${each.key}_license"]
    format          = "${var.t1_license_format}"
    port1_ip        = each.value.t1nic-ext_ipaddr
    port1_mask      = each.value.t1nic-ext_mask
    port2_ip        = each.value.t1nic-int_ipaddr
    port2_mask      = each.value.t1nic-int_mask
    port3_ip        = each.value.t1nic-hasync_ipaddr
    port3_mask      = each.value.t1nic-hasync_mask
    port4_ip        = each.value.t1nic-mgmt_ipaddr
    port4_mask      = each.value.t1nic-mgmt_mask
    peerip          = each.value.peer-hasync_ipaddr
    mgmt_gateway_ip = var.port4gateway
    defaultgwy      = var.port1gateway
    adminsport      = var.adminsport
    rsg             = azurerm_resource_group.rg.name
    routename       = "eit-uks-alz-t1fw-int-udr-01"
  }
}

```

## Code Quality

A number of tests are run against code as part of the GitHub super linter, as such they are not documented here other than links

### Super Linter

- All checks as defined inside the [GitHub super-linter](https://github.com/github/super-linter)

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

| Name                                                                     | Version           |
| ------------------------------------------------------------------------ | ----------------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >=1.3.0           |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm)       | >= 3.3.0, < 4.0.0 |
| <a name="requirement_random"></a> [random](#requirement_random)          | >= 3.5.1          |

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | 3.112.0 |
| <a name="provider_random"></a> [random](#provider_random)    | 3.6.2   |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                   | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [azurerm_key_vault_key.kek](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key)                                                             | resource |
| [azurerm_key_vault_secret.password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret)                                                  | resource |
| [azurerm_key_vault_secret.username](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret)                                                  | resource |
| [azurerm_managed_disk.disks_data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk)                                                        | resource |
| [azurerm_managed_disk.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk)                                                              | resource |
| [azurerm_network_interface.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)                                                    | resource |
| [azurerm_network_interface.nics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface)                                                    | resource |
| [azurerm_virtual_machine.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine)                                                        | resource |
| [azurerm_virtual_machine_data_disk_attachment.disks_data_attach](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password)                                                                    | resource |

## Inputs

| Name                                                                                                                     | Description                                                                                                                                                                                                                                                                    | Type                                                                                                                                                                                                                                                    | Default                                                                                                                                                                                     | Required |
| ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_availability_zone"></a> [availability_zone](#input_availability_zone)                                     | Azure Availability Zone for VM and disks.                                                                                                                                                                                                                                      | `number`                                                                                                                                                                                                                                                | `null`                                                                                                                                                                                      |    no    |
| <a name="input_data_disks"></a> [data_disks](#input_data_disks)                                                          | [OPTIONAL] Data disks to create or copy and attach.                                                                                                                                                                                                                            | `map(any)`                                                                                                                                                                                                                                              | `{}`                                                                                                                                                                                        |    no    |
| <a name="input_enable_accelerated_networking"></a> [enable_accelerated_networking](#input_enable_accelerated_networking) | Flag to enable accelerated networking on the VM's network interface.                                                                                                                                                                                                           | `bool`                                                                                                                                                                                                                                                  | `null`                                                                                                                                                                                      |    no    |
| <a name="input_identity_ids"></a> [identity_ids](#input_identity_ids)                                                    | [OPTIONAL] Specifies a list of user assigned managed identity IDs for the VM.                                                                                                                                                                                                  | `list(string)`                                                                                                                                                                                                                                          | `[]`                                                                                                                                                                                        |    no    |
| <a name="input_identity_type"></a> [identity_type](#input_identity_type)                                                 | [OPTIONAL] Specifies the type of managed service identity for the VM.                                                                                                                                                                                                          | `string`                                                                                                                                                                                                                                                | `null`                                                                                                                                                                                      |    no    |
| <a name="input_network_subnet_name"></a> [network_subnet_name](#input_network_subnet_name)                               | Name of the subnet NIC should be deployed to.                                                                                                                                                                                                                                  | `string`                                                                                                                                                                                                                                                | n/a                                                                                                                                                                                         |   yes    |
| <a name="input_nics"></a> [nics](#input_nics)                                                                            | [OPTIONAL] Multiple network interfaces to create and attach to vm.                                                                                                                                                                                                             | <pre>map(object({<br> enable_accelerated_networking = optional(bool, null)<br> ip_configurations = optional(map(object({<br> subnet_id = string<br> private_ip_address = string<br> private_ip_address_allocation = string<br> })), null)<br> }))</pre> | `{}`                                                                                                                                                                                        |    no    |
| <a name="input_resource_group_location"></a> [resource_group_location](#input_resource_group_location)                   | Resource Group location.                                                                                                                                                                                                                                                       | `string`                                                                                                                                                                                                                                                | n/a                                                                                                                                                                                         |   yes    |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name)                               | Resource Group name.                                                                                                                                                                                                                                                           | `string`                                                                                                                                                                                                                                                | n/a                                                                                                                                                                                         |   yes    |
| <a name="input_subscription_env_config"></a> [subscription_env_config](#input_subscription_env_config)                   | Object containing Subscription specific values.                                                                                                                                                                                                                                | `map(any)`                                                                                                                                                                                                                                              | n/a                                                                                                                                                                                         |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                            | Map of tags to apply to all possible resources.                                                                                                                                                                                                                                | `map(any)`                                                                                                                                                                                                                                              | n/a                                                                                                                                                                                         |   yes    |
| <a name="input_vm_hyper_v_generation"></a> [vm_hyper_v_generation](#input_vm_hyper_v_generation)                         | [OPTIONAL] Hyper-V Generation, possible values are V1 or V2.                                                                                                                                                                                                                   | `string`                                                                                                                                                                                                                                                | `null`                                                                                                                                                                                      |    no    |
| <a name="input_vm_name"></a> [vm_name](#input_vm_name)                                                                   | Name for VM resources to be deployed with.                                                                                                                                                                                                                                     | `string`                                                                                                                                                                                                                                                | n/a                                                                                                                                                                                         |   yes    |
| <a name="input_vm_osdisk_size_gb"></a> [vm_osdisk_size_gb](#input_vm_osdisk_size_gb)                                     | Size of OS disk to be deployed.                                                                                                                                                                                                                                                | `string`                                                                                                                                                                                                                                                | n/a                                                                                                                                                                                         |   yes    |
| <a name="input_vm_setting_tags"></a> [vm_setting_tags](#input_vm_setting_tags)                                           | Tags used for managing Virtual Machines in the project for automation purposes. Tags such as UpdateWindow which governs the patching schedule for the VM, Backup to initiate an automated backup schedule and ssv2excludevm to exclude the VM from automated start/stop action | `map(any)`                                                                                                                                                                                                                                              | `{}`                                                                                                                                                                                        |    no    |
| <a name="input_vm_size"></a> [vm_size](#input_vm_size)                                                                   | VM Size, in Standard_B1s format.                                                                                                                                                                                                                                               | `string`                                                                                                                                                                                                                                                | n/a                                                                                                                                                                                         |   yes    |
| <a name="input_vm_username"></a> [vm_username](#input_vm_username)                                                       | [OPTIONAL] Specifies username for the VM.                                                                                                                                                                                                                                      | `string`                                                                                                                                                                                                                                                | `null`                                                                                                                                                                                      |    no    |
| <a name="input_vm_password"></a> [vm_password](#input_vm_password)                                                       | [OPTIONAL] Specifies password for the VM.                                                                                                                                                                                                                                      | `string`                                                                                                                                                                                                                                                | `null`                                                                                                                                                                                      |    no    |
| <a name="input_fgtvm_custom_data"></a> [fgtvm_custom_data](#input_fgtvm_custom_data)                                     | [OPTIONAL] Provide a fortigate bootstrap script.                                                                                                                                                                                                                               | `string`                                                                                                                                                                                                                                                | `null`                                                                                                                                                                                      |    no    |
| <a name="input_license_type"></a> [license_type](#input_license_type)                                                    | License Type to create FortiGate VM. Values: byol or payg                                                                                                                                                                                                                      | `string`                                                                                                                                                                                                                                                | `payg`                                                                                                                                                                                      |    no    |
| <a name="input_fgtoffer"></a> [fgtoffer](#input_fgtoffer)                                                                | Offer for the VM Image                                                                                                                                                                                                                                                         | `string`                                                                                                                                                                                                                                                | `fortinet_fortigate-vm_v5`                                                                                                                                                                  |    no    |
| <a name="input_fgtsku"></a> [fgtsku](#input_fgtsku)                                                                      | SKU                                                                                                                                                                                                                                                                            | `map(any)`                                                                                                                                                                                                                                              | <pre>x86 = {<br> byol = "fortinet_fg-vm"<br> payg = "fortinet_fg-vm_payg_2023"<br> },<br> arm = {<br> byol = "fortinet_fg-vm_arm64"<br> payg = "fortinet_fg-vm_payg_2023_arm64"<br> }</pre> |    no    |
| <a name="input_fgtversion"></a> [fgtversion](#input_fgtversion)                                                          | FortiGate Image version                                                                                                                                                                                                                                                        | `string`                                                                                                                                                                                                                                                | `7.0.14`                                                                                                                                                                                    |    no    |
| <a name="input_arch"></a> [arch](#input_arch)                                                                            | Instance architecture, either arm or x86                                                                                                                                                                                                                                       | `string`                                                                                                                                                                                                                                                | `x86`                                                                                                                                                                                       |    no    |
| <a name="input_accept_marketplace_agreement"></a> [accept_marketplace_agreement](#input_accept_marketplace_agreement)    | To accept marketplace agreement for deployed FortiGate image                                                                                                                                                                                                                   | `bool`                                                                                                                                                                                                                                                  | `false`                                                                                                                                                                                     |    no    |
| <a name="input_enable_encryption_at_host"></a> [enable_encryption_at_host](#input_enable_encryption_at_host)             | all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host                                                                                                                                                        | `bool`                                                                                                                                                                                                                                                  | `false`                                                                                                                                                                                     |    no    |

## Outputs

| Name                                                                                                        | Description                                                    |
| ----------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| <a name="output_availability_zone"></a> [availability_zone](#output_availability_zone)                      | List of Azure Availability Zone VM and disks are allocated to. |
| <a name="output_nic_dns_servers"></a> [nic_dns_servers](#output_nic_dns_servers)                            | DNS Servers on NIC.                                            |
| <a name="output_vm_network_interface_ids"></a> [vm_network_interface_ids](#output_vm_network_interface_ids) | List of NIC IDs                                                |
| <a name="output_vm_private_ips"></a> [vm_private_ips](#output_vm_private_ips)                               | List of Private IP addresses associated with VM                |
| <a name="output_nics"></a> [nics](#output_nics)                                                             | Export objects of NICs.                                        |
| <a name="output_vm"></a> [vm](#output_vm)                                                                   | Export of full vm object.                                      |
| <a name="output_vm_id"></a> [vm_id](#output_vm_id)                                                          | ID of VM.                                                      |
| <a name="output_vm_identity"></a> [vm_identity](#output_vm_identity)                                        | Identity used by VM.                                           |
| <a name="output_data_disk_ids"></a> [data_disk_ids](#output_data_disk_ids)                                  | List of Data Disk IDs                                          |
| <a name="output_os_disk_name"></a> [os_disk_name](#output_os_disk_name)                                     | OS Disk Name                                                   |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
