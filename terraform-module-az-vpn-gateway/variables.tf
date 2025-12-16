variable "resource_group_name" {
  type        = string
  description = "The resource group that will be used for the deployment."
}

variable "location" {
  type        = string
  description = "The Azure location where the resources will be deployed."
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to assign to the resources."
  default     = {}
}

variable "zones" {
  type        = list(number)
  description = "The Availability zones where the resources should be deployed."
  default     = null
}

variable "key_vault_id" {
  type        = string
  description = "ID of the Azure Key Vault which holds the shared keys used to create the VPN connections."
}

variable "gateway_pip_name" {
  type        = string
  description = "The name to assign to the public IP address required by the VPN gateway."
}

variable "gateway_name" {
  type        = string
  description = "Name of the VPN gateway to deploy"
}

variable "gateway_ip_config_name" {
  type        = string
  description = "If specified, gives a custom name for the IP configuration used for the VPN gateway."
  default     = null
}

variable "gateway_sku" {
  type        = string
  description = "Sku of the gateway that will be deployed."
}

variable "gateway_subnet_id" {
  type        = string
  description = "The subnet ID where the gateway should be placed."
}

variable "vpn_connections" {
  type = map(object({
    egress_nat_rule_ids        = optional(list(string), null)
    ingress_nat_rule_ids       = optional(list(string), null)
    dh_group                   = string
    dpd_timeout_seconds        = optional(number, null)
    ike_encryption             = string
    ike_integrity              = string
    ipsec_encryption           = string
    ipsec_integrity            = string
    local_network_gateway_name = string
    pfs_group                  = string
    remote_address_space       = list(string)
    remote_gateway_address     = string
    shared_key_secret_name     = string
    traffic_selector_policies = optional(list(object({
      local_address_cidrs  = list(string)
      remote_address_cidrs = list(string)
    })), null)
  }))
  description = "Map of VPN connections and local network gateways to create."
  default     = {}
}

variable "nat_rules" {
  type = map(object({
    nat_mode                    = string
    nat_type                    = string
    external_mapping_subnet     = string
    external_mapping_port_range = optional(string, null)
    internal_mapping_subnet     = string
    internal_mapping_port_range = optional(string, null)
  }))
  description = "Map of Virtual Network Gateway Nat Rules"
  default     = {}
}
