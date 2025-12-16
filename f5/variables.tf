variable "availability_zone" {
  default     = null
  description = "Azure Availability Zone for VM and disks."
  type        = string
}

variable "resource_group_location" {
  description = "Resource Group location."
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name."
  type        = string
}

variable "subscription_env_config" {
  description = "Object containing Subscription specific values."
  type        = map(any)
}

variable "tags" {
  description = "Map of tags to apply to all possible resources."
  type        = map(any)
}

variable "vm_name" {
  description = "Name for VM resources to be deployed with."
  sensitive   = true
  type        = string
  validation {
    condition = (
      length(var.vm_name) < 16
    )
    error_message = "VM Name must be 15 characters or less."
  }
}

variable "vm_osdisk_size_gb" {
  description = "Size of OS disk to be deployed."
  type        = string
}

variable "storage_account_type" {
  description = "Disk type used for OS disk."
  type        = string
  default = "Premium_LRS"
}

variable "ephemeral_os_disk" {
  description = "Linux Virtual Machine with an Ephemeral OS Disk."
  type        = bool
  default = false
}

variable "vm_size" {
  description = "F5 Big-IP VM Size"
  type        = string
  default = "Standard_DS4_v2"
}

variable "data_disks" {
  default     = {}
  description = "[OPTIONAL] Data disks to create or copy and attach."
  type        = map(any)
}

variable "enable_encryption_at_host" {
  default     = false
  description = "all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host"
  type        = bool
}

variable "nics" {
  default     = {}
  description = "Network interfaces to create and attach to vm."
  type = map(object({
    name = optional(string, null)
    enable_accelerated_networking = optional(bool, null)
    enable_ip_forwarding = optional(bool, null)
    ip_configurations = optional(map(object({
      subnet_id                     = string
      private_ip_address            = string
      private_ip_address_allocation = string
    })), null)
  }))
}

variable "vm_hyper_v_generation" {
  default     = null
  description = "[OPTIONAL] Hyper-V Generation, possible values are V1 or V2."
  type        = string
}

variable "vm_setting_tags" {
  default     = {}
  description = "Tags used for managing Virtual Machines in the project for automation purposes. Tags such as UpdateWindow which governs the patching schedule for the VM, Backup to initiate an automated backup schedule and ssv2excludevm to exclude the VM from automated start/stop action"
  type        = map(any)
}

variable "identity_type" {
  default     = null
  description = "[OPTIONAL] Specifies the type of managed service identity for the VM."
  type        = string
  validation {
    condition     = (var.identity_type == null || can(regex("^$|^SystemAssigned$|^UserAssigned$|^SystemAssigned, UserAssigned$", var.identity_type)))
    error_message = "Error: identity_type does match one of the following 'SystemAssigned' 'UserAssigned' or 'SystemAssigned, UserAssigned'"
  }
}

variable "identity_ids" {
  default     = []
  description = "[OPTIONAL] Specifies a list of user assigned managed identity IDs for the VM."
  type        = list(string)
}

variable "vm_username" {
  default     = null
  description = "[OPTIONAL] Specifies username for the VM. "
  type        = string
}

variable "vm_password" {
  default     = null
  sensitive   = true
  description = "[OPTIONAL] Specifies password for the VM."
  type        = string
}

variable "f5vm_custom_script" {
  description = "Provide a fortigate bootstrap script."
  type        = string
  default     = null
}

variable "license_type" {
  description = "License Type to create FortiGate VM. Values: byol or payg."
  type = string
  default = "payg"
}

variable "f5_offer" {
  description = "Offer for the VM Image"
  type = map(any)
  default = {
      byol = "f5-big-ip-byol"
      payg = "f5-big-ip-best"
  }
}

variable "f5_sku" {
  description = "SKU"
  type = map(any)
  default = {
      byol = "f5-big-all-2slot-byol"
      payg = "f5-big-best-plus-hourly-25mbps"   #f5-big-best-plus-hourly-10gbps
  }
}

variable "f5_version" {
  description = "F5 Big-IP Image version"
  type    = string
  default = "17.1.103000"
}

variable "accept_marketplace_agreement" {
  description = "To accept marketplace agreement for deployed FortiGate image."
  type = bool
  default = false
}

variable "backup_storage_account_id" {
  description = "Storage account ID, where UCS cinfiguration files are backed up"
  type = string
  default = null
}

variable "f5_private_endpoint_name" {
  description = "Private endpoint deployed to access Storage Account using Azure network"
  type = string
  default = "f5pep"
}

# variable "pep_private_dns_rg_id" {
#   type        = string
#   description = "ID of the resource group where the private DNS zones exist for association with the private endpoints."
#   default     = null
# }
# variable "private_endpoint_subnet_id" {
#   type        = string
#   description = "The subnet ID where the private endpoints will be created."
#   default     = null
# }

# variable "private_service_connection_name" {
#   type        = string
#   description = "Specifies a custom name for the private service connection, mainly used for dealing with existing resources."
#   default     = null
# }