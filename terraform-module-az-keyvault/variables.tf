variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "keyvault_name" {
  description = "[OPTIONAL] Name of the Keyvault"
  type        = string
  default     = null
}

variable "company_identifier" {
  description = "[OPTIONAL] Company identifier."
  type        = string
  validation {
    condition     = contains(["eit", "hub", "cus", "gen", "hpc", "szc"], var.company_identifier)
    error_message = "Company identifier name is not supported. Refer to module documentation."
  }
  default = "eit"
}

variable "environment" {
  description = "[OPTIONAL] The name of the environment"
  type        = string
  validation {
    condition     = contains(["alz", "prd", "dev", "pre", "tst", "stg", "uat"], var.environment)
    error_message = "Environment name shall adhere to azure naming convention. This is not supported."
  }
  default = "stg"
}

variable "data_classification" {
  description = "[OPTIONAL] Data classification level."
  type        = string
  validation {
    condition     = contains(["ss", "hs"], var.data_classification)
    error_message = "Data classification for the given resource has to be labelled either 'ss' or 'hs' to adhere to azure naming convention. This is not supported."
  }
  default = "hs"
}

variable "location" {
  description = "[OPTIONAL] Provide location to deploy azure pipeline resources"
  type        = string
  validation {
    condition     = contains(["uksouth", "ukwest"], var.location)
    error_message = "Deploying Azure Pipeline to specified location is not supported. Refer to module documentation."
  }
  default = "uksouth"
}

variable "tags_override" {
  description = "[OPTIONAL] Common Tags for Azure Resources"
  type        = map(string)
  default     = {}
}

variable "acl_ip_rules" {
  description = "[OPTIONAL] One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault."
  type        = list(string)
  default     = []
}

variable "virtual_network_subnet_ids" {
  description = "[OPTIONAL] One or more Subnets which should be able to access the Key Vault."
  type        = list(string)
  default     = []
}

variable "public_network_access_enabled" {
  description = "[OPTIONAL] Whether public network access is allowed for this Key Vault. Defaults to true."
  type        = bool
  default     = true
}

variable "access_policy_for_key_vault_standard_access" {
  description = "[OPTIONAL] Lists of UPNs and SPNs that will be granted standard access to the key vault. upn, spn, or group need to be the object name, and require Entra read access to the object."
  type = object({
    upn   = optional(list(string), [])
    spn   = optional(list(string), [])
    group = optional(list(string), [])
    oids  = optional(list(string), [])
  })
  default = {}
}

variable "access_policy_for_key_vault_encryption_at_host_access" {
  description = "[OPTIONAL] Lists of UPNs and SPNs that will be granted encryption at host access to the key vault.  upn, spn, or group need to be the object name, and require Entra read access to the object."
  type = object({
    upn   = optional(list(string), [])
    spn   = optional(list(string), [])
    group = optional(list(string), [])
    oids  = optional(list(string), [])
  })
  default = {}
}

variable "enable_rbac_authorization" {
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions."
  type        = bool
  default     = false
}

variable "key_vault_rbac_access" {
  description = "[OPTIONAL] Lists of SPNs and users that will be granted access to the key vault via Azure RBAC for the roles found at [Azure built-in roles for Key Vault data plane operations.](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide#azure-built-in-roles-for-key-vault-data-plane-operations)"
  type = object({
    key_vault_administrator = optional(object({
      spns   = optional(list(string), [])
      users  = optional(list(string), [])
      groups = optional(list(string), [])
    }), {})
    key_vault_reader = optional(object({
      spns   = optional(list(string), [])
      users  = optional(list(string), [])
      groups = optional(list(string), [])
    }), {})
    key_vault_purge_operator = optional(object({
      spns   = optional(list(string), [])
      users  = optional(list(string), [])
      groups = optional(list(string), [])
    }), {})
    key_vault_certificates_officer = optional(object({
      spns   = optional(list(string), [])
      users  = optional(list(string), [])
      groups = optional(list(string), [])
    }), {})
    key_vault_certificate_user = optional(object({
      spns   = optional(list(string), [])
      users  = optional(list(string), [])
      groups = optional(list(string), [])
    }), {})
    key_vault_crypto_officer = optional(object({
      spns   = optional(list(string), [])
      users  = optional(list(string), [])
      groups = optional(list(string), [])
    }), {})
    key_vault_crypto_service_encryption_user = optional(object({
      spns   = optional(list(string), [])
      users  = optional(list(string), [])
      groups = optional(list(string), [])
    }), {})
    key_vault_crypto_user = optional(object({
      spns   = optional(list(string), [])
      users  = optional(list(string), [])
      groups = optional(list(string), [])
    }), {})
    key_vault_crypto_service_release_user = optional(object({
      spns   = optional(list(string), [])
      users  = optional(list(string), [])
      groups = optional(list(string), [])
    }), {})
    key_vault_secrets_officer = optional(object({
      spns   = optional(list(string), [])
      users  = optional(list(string), [])
      groups = optional(list(string), [])
    }), {})
    key_vault_secrets_user = optional(object({
      spns   = optional(list(string), [])
      users  = optional(list(string), [])
      groups = optional(list(string), [])
    }), {})
  })
  default = {}
}

variable "enabled_for_disk_encryption" {
  description = "[OPTIONAL] Used to enable Azure Disk Encryption. Which creates a 'premium' SKU type."
  type        = bool
  default     = false
}

variable "enable_private_endpoint" {
  description = "[OPTIONAL] Whether to set up a private endpoint and allow Key Vault access only from the endpoint."
  type        = bool
  default     = false
}

variable "enabled_for_deployment" {
  description = "[OPTIONAL] Can Azure Virtual Machines retrieve certificates stored as secrets from the Key Vault?"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "[OPTIONAL] Can Azure Resource Manager retrieve secrets from the key Vault?"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "[OPTIONAL] The subnet ID where the private endpoints will be created."
  default     = null
}

variable "pep_private_dns_rg_id" {
  type        = string
  description = "[OPTIONAL] ID of the resource group where the private DNS zones exist for association with the private endpoints."
  default     = null
}

variable "private_endpoint_name" {
  type        = string
  description = "[OPTIONAL] Specifies a custom name for the private endpoint, mainly used for dealing with existing resources."
  default     = null
}

variable "private_service_connection_name" {
  type        = string
  description = "[OPTIONAL] Specifies a custom name for the private service connection, mainly used for dealing with existing resources."
  default     = null
}

variable "central_audit_law_workspace_id" {
  description = "[OPTIONAL] Log Analytics Workspace ID for Central Audit."
  type        = string
  default     = null
}

variable "mgmt_law_workspace_id" {
  description = "[OPTIONAL] Log Analytics Workspace ID for Management."
  type        = string
  default     = null
}

variable "purge_protection_enabled" {
  description = "[OPTIONAL] Is Purge Protection enabled for this Key Vault?"
  type        = bool
  default     = true
}


variable "soft_delete_retention_days" {
  description = "[OPTIONAL] The number of days that items should be retained for once soft deleted. Must be between 7 and 90."
  type        = number
  default     = 90
}

variable "kv_sku" {
  description = "[OPTIONAL] Optionally override the SKU for the Key Vault when using Azure Disk Encryption."
  type        = string
  default     = null
}

variable "disable_default_access_policies" {
  description = "[OPTIONAL] Switch to disable default access policies."
  type        = bool
  default     = false
}

variable "acl_default_action" {
  description = "[OPTIONAL] Default action for Network ACL, must be set to Allow or Deny."
  type        = string
  default     = "Deny"
}

###################################################
#               Disk Encryption Set               #
###################################################

variable "enable_encryption_at_host" {
  description = "[OPTIONAL] Used to enable Encryption at Host. Which creates a 'premium' SKU type."
  type        = bool
  default     = false
}

variable "disk_encryption_set" {
  description = "A map of Disk Encryption Set (DES). The map Key is used for the name of the DES"
  type = map(object({
    resource_group_name = optional(string, null)
  }))
  default = {}
}
