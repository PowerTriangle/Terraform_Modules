# terraform-module-az-load-balancer
Terraform module for Azure load balancers

This module has been adapted from code from the [PaloAltoNetworks/terraform-azurerm-vmseries-modules project.](https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/tree/v1.0.5/modules/loadbalancer/)

## Changelog Guide

Refer to below guide to learn how `CHANGELOG.md` gets updated
<https://digitalcentral.edfenergy.com/pages/viewpage.action?pageId=186029053>

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.25.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_lb.lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.lb_backend](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_outbound_rule.out_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_outbound_rule) | resource |
| [azurerm_lb_probe.probe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_probe.probes](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.in_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_network_security_rule.allow_inbound_ips](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/public_ip) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_avzones"></a> [avzones](#input\_avzones) | Controls zones for load balancer's Fronted IP configurations. For:<br><br>public IPs - these are regions in which the IP resource is available<br>private IPs - this represents Zones to which Azure will deploy paths leading to this Frontend IP.<br><br>For public IPs, after provider version 3.x (Azure API upgrade) you need to specify all zones available in a region (typically 3), ie: for zone-redundant with 3 availability zone in current region value will be:<pre>["1","2","3"]</pre> | `list(string)` | `[]` | no |
| <a name="input_backend_name"></a> [backend\_name](#input\_backend\_name) | The name of the backend pool to create. All the frontends of the load balancer always use the same single backend. | `string` | n/a | yes |
| <a name="input_enable_zones"></a> [enable\_zones](#input\_enable\_zones) | If `false`, all the subnet-associated frontends and also all created Public IP addresses default to not to use Availability Zones (the `No-Zone` setting). It is intended for the regions that do not yet support Availability Zones. | `bool` | `true` | no |
| <a name="input_frontend_ips"></a> [frontend\_ips](#input\_frontend\_ips) | A map of objects describing LB Frontend IP configurations, inbound and outbound rules. Used for both public or private load balancers.<br>Keys of the map are names of LB Frontend IP configurations.<br><br>Each Frontend IP configuration can have multiple rules assigned. They are defined in a maps called `in_rules` and `out_rules` for inbound and outbound rules respectively. A key in this map is the name of the rule, while value is the actual rule configuration. To understand this structure please see examples below.<br><br>**Inbound rules.**<br><br>Here is a list of properties supported by each `in_rule`:<br><br>- `name` : Optional name to give to the rule.<br>- `protocol` : required, communication protocol, either 'Tcp', 'Udp' or 'All'.<br>- `port` : required, communication port, this is both the front- and the backend port if `backend_port` is not given.<br>- `probe` : Optional if using the `probe_name` variable with a single health probe. If the `probe_name` variable is set, then its assumed that all inbound rules will use the same health probe. However, if you are defining multiple probes using the `probes` variable, then this field needs to be set to the probe key you want to use to assign to the inbound rule.<br>- `backend_port` : optional, this is the backend port to forward traffic to in the backend pool.<br>- `floating_ip` : optional, defaults to `true`, enables floating IP for this rule.<br>- `session_persistence` : optional, defaults to 5 tuple (Azure default), see `Session persistence/Load distribution` below for details.<br><br>Public LB<br><br>- `create_public_ip` : Optional. Set to `true` to create a public IP.<br>- `public_ip_name` : optional if `create_public_ip` is `true`, required if not. If creating a public IP, its possible to specify a custom IP name using this field, otherwise a default value will be used. If using an existing IP, this needs to be set to the name of the public IP to use.<br>- `public_ip_resource_group` : Ignored if `create_public_ip` is `true` or if `public_ip_name` is null. The name of the resource group which holds `public_ip_name`.<br><br>Example<pre>frontend_ips = {<br>  pip_existing = {<br>    create_public_ip         = false<br>    public_ip_name           = "my_ip"<br>    public_ip_resource_group = "my_rg_name"<br>    in_rules = {<br>      HTTP = {<br>        port         = 80<br>        protocol     = "Tcp"<br>      }<br>    }<br>  }<br>}</pre>Forward to a different port on backend pool<pre>frontend_ips = {<br>  pip_existing = {<br>    create_public_ip         = false<br>    public_ip_name           = "my_ip"<br>    public_ip_resource_group = "my_rg_name"<br>    in_rules = {<br>      HTTP = {<br>        port         = 80<br>        backend_port = 8080<br>        protocol     = "Tcp"<br>      }<br>    }<br>  }<br>}</pre>Private LB<br><br>- `subnet_id` : Identifier of an existing subnet. This also trigger creation of an internal LB.<br>- `private_ip_address` : A static IP address of the Frontend IP configuration, has to be in limits of the subnet's (specified by `subnet_id`) address space. When not set, changes the address allocation from `Static` to `Dynamic`.<br><br>Example<pre>frontend_ips = {<br>  internal_fe = {<br>    subnet_id                     = azurerm_subnet.this.id<br>    private_ip_address            = "192.168.0.10"<br>    in_rules = {<br>      HA_PORTS = {<br>        port         = 0<br>        protocol     = "All"<br>      }<br>    }<br>  }<br>}</pre>Session persistence/Load distribution<br><br>By default the load balancer uses a 5 tuple hash to map traffic to available servers. This can be controlled using `session_persistence` property defined inside a role. Available values are:<br><br>- `Default` : this is the 5 tuple hash - this method is also used when no property is defined<br>- `SourceIP` : a 2 tuple hash is used<br>- `SourceIPProtocol` : a 3 tuple hash is used<br><br>Example<pre>frontend_ips = {<br>    rule_1 = {<br>      create_public_ip = true<br>      in_rules = {<br>        HTTP = {<br>          port     = 80<br>          protocol = "Tcp"<br>          session_persistence = "SourceIP"<br>        }<br>      }<br>    }<br>  }</pre>**Outbound rules.**<br><br>Each Frontend IP config can have outbound rules specified. Setting at least one `out_rule` switches the outgoing traffic from SNAT to Outbound rules. Keep in mind that since we use a single backend, and you cannot mix SNAT and Outbound rules traffic in rules using the same backend, setting one `out_rule` switches the outgoing traffic route for **ALL** `in_rules`.<br><br>Following properties are available:<br><br>- `name` : Optional name to give to the rule.<br>- `protocol` : Protocol used by the rule. On of `All`, `Tcp` or `Udp` is accepted.<br>- `allocated_outbound_ports` : Number of ports allocated per instance. Defaults to `1024`.<br>- `enable_tcp_reset` : Ignored when `protocol` is set to `Udp`, defaults to `False` (Azure defaults).<br>- `idle_timeout_in_minutes` : Ignored when `protocol` is set to `Udp`. TCP connection timeout in case the connection is idle. Defaults to 4 minutes (Azure defaults).<br><br>Example:<pre>frontend_ips = {<br>  rule_1 = {<br>    create_public_ip = true<br>    in_rules = {<br>      HTTP = {<br>        port     = 80<br>        protocol = "Tcp"<br>        session_persistence = "SourceIP"<br>      }<br>    }<br>    out_rules = {<br>      "outbound_tcp" = {<br>        protocol                 = "Tcp"<br>        allocated_outbound_ports = 2048<br>        enable_tcp_reset         = true<br>        idle_timeout_in_minutes  = 10<br>      }<br>    }<br>  }<br>}</pre> | `any` | n/a | yes |
| <a name="input_frontend_ips_order"></a> [frontend\_ips\_order](#input\_frontend\_ips\_order) | When importing existing load balancers into the state, it is required to preserve the order of the frontend IP configurations in the load balancer. The maps use lexical sorting, which is a problem in some cases. Using this list allows the order to be preserved during the import stage. | `list(string)` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Region to deploy load balancer and dependencies. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the load balancer. | `string` | n/a | yes |
| <a name="input_network_security_allow_source_ips"></a> [network\_security\_allow\_source\_ips](#input\_network\_security\_allow\_source\_ips) | List of IP CIDR ranges (such as `["192.168.0.0/16"]` or `["*"]`) from which the inbound traffic to all frontends should be allowed.<br>If it's empty, user is responsible for configuring a Network Security Group separately.<br>The list cannot include Azure tags like "Internet" or "Sql.EastUS". | `list(string)` | `[]` | no |
| <a name="input_network_security_base_priority"></a> [network\_security\_base\_priority](#input\_network\_security\_base\_priority) | The base number from which the auto-generated priorities of the NSG rules grow.<br>Ignored if `network_security_group_name` is empty or if `network_security_allow_source_ips` is empty. | `number` | `1000` | no |
| <a name="input_network_security_group_name"></a> [network\_security\_group\_name](#input\_network\_security\_group\_name) | Name of the pre-existing Network Security Group (NSG) where to add auto-generated rules. Each NSG rule corresponds to a single `in_rule` on the load balancer.<br>User is responsible to associate the NSG with the load balancer's subnet, the module only supplies the rules.<br>If empty, user is responsible for configuring an NSG separately. | `string` | `null` | no |
| <a name="input_network_security_resource_group_name"></a> [network\_security\_resource\_group\_name](#input\_network\_security\_resource\_group\_name) | Name of the Resource Group where the `network_security_group_name` resides. If empty, defaults to `resource_group_name`. | `string` | `null` | no |
| <a name="input_probe_interval_in_seconds"></a> [probe\_interval\_in\_seconds](#input\_probe\_interval\_in\_seconds) | Interval of the load balancer probe. | `number` | `5` | no |
| <a name="input_probe_name"></a> [probe\_name](#input\_probe\_name) | The name of the load balancer probe. | `string` | `null` | no |
| <a name="input_probe_port"></a> [probe\_port](#input\_probe\_port) | Health check port number of the load balancer probe. | `number` | `80` | no |
| <a name="input_probe_protocol"></a> [probe\_protocol](#input\_probe\_protocol) | Protocol of the load balancer probe. | `string` | `"Tcp"` | no |
| <a name="input_probes"></a> [probes](#input\_probes) | Health probes you want to be created on the load balancer, the key is the name of the health probe. | <pre>map(object({<br>    port                = optional(number, 80)<br>    protocol            = optional(string, "Tcp")<br>    interval_in_seconds = optional(number, 5)<br>    number_of_probes    = optional(number, 2)<br>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of a pre-existing Resource Group to place the resources in. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Azure tags to apply to the created resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_pool_id"></a> [backend\_pool\_id](#output\_backend\_pool\_id) | The identifier of the backend pool. |
| <a name="output_frontend_combined_rules"></a> [frontend\_combined\_rules](#output\_frontend\_combined\_rules) | Map of all inbound rules used by the load balancer. |
| <a name="output_frontend_ip_configs"></a> [frontend\_ip\_configs](#output\_frontend\_ip\_configs) | Map of IP addresses, one per each entry of `frontend_ips` input. Contains public IP address for the frontends that have it, private IP address otherwise. |
| <a name="output_health_probe"></a> [health\_probe](#output\_health\_probe) | The health probe object. |
| <a name="output_load_balancer_name"></a> [load\_balancer\_name](#output\_load\_balancer\_name) | The name of the load balancer. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
