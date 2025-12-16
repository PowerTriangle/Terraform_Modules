# terraform-module-az-vpn-gateway
Terraform module for az-vpn-gateway

## Changelog Guide

Refer to below guide to learn how `CHANGELOG.md` gets updated
<https://digitalcentral.edfenergy.com/pages/viewpage.action?pageId=186029053>

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.3.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.62.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_local_network_gateway.vpn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway) | resource |
| [azurerm_public_ip.vpn_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_network_gateway.vpn_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |
| [azurerm_virtual_network_gateway_connection.vpn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource |
| [azurerm_key_vault_secret.shared_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gateway_ip_config_name"></a> [gateway\_ip\_config\_name](#input\_gateway\_ip\_config\_name) | If specified, gives a custom name for the IP configuration used for the VPN gateway. | `string` | `null` | no |
| <a name="input_gateway_name"></a> [gateway\_name](#input\_gateway\_name) | Name of the VPN gateway to deploy | `string` | n/a | yes |
| <a name="input_gateway_pip_name"></a> [gateway\_pip\_name](#input\_gateway\_pip\_name) | The name to assign to the public IP address required by the VPN gateway. | `string` | n/a | yes |
| <a name="input_gateway_sku"></a> [gateway\_sku](#input\_gateway\_sku) | Sku of the gateway that will be deployed. | `string` | n/a | yes |
| <a name="input_gateway_subnet_id"></a> [gateway\_subnet\_id](#input\_gateway\_subnet\_id) | The subnet ID where the gateway should be placed. | `string` | n/a | yes |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | ID of the Azure Key Vault which holds the shared keys used to create the VPN connections. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure location where the resources will be deployed. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group that will be used for the deployment. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the resources. | `map(string)` | `{}` | no |
| <a name="input_vpn_connections"></a> [vpn\_connections](#input\_vpn\_connections) | Map of VPN connections and local network gateways to create. | <pre>map(object({<br>    dh_group                   = string<br>    dpd_timeout_seconds        = optional(number, null)<br>    ike_encryption             = string<br>    ike_integrity              = string<br>    ipsec_encryption           = string<br>    ipsec_integrity            = string<br>    local_network_gateway_name = string<br>    pfs_group                  = string<br>    remote_address_space       = list(string)<br>    remote_gateway_address     = string<br>    shared_key_secret_name     = string<br>    traffic_selector_policies = optional(list(object({<br>      local_address_cidrs  = list(string)<br>      remote_address_cidrs = list(string)<br>    })), null)<br>  }))</pre> | `{}` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | The Availability zones where the resources should be deployed. | `list(number)` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
