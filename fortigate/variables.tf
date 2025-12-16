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

##write accelerator cannot be enabled if caching type is read write
# variable "enable_write_accelerator" {
#   description = "Write Accelerator can not be Enabled for this OS Disk - OS image and CPU requirements"
#   type        = string
#   default = false
# }

variable "ephemeral_os_disk" {
  description = "Linux Virtual Machine with an Ephemeral OS Disk."
  type        = bool
  default = false
}

variable "vm_size" {
  description = "FortiGate VM Size"
  type        = string
  default = "Standard_F8s_v2"
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

# commenting out variable since enable secure boot should always be set to false due to it not supporting fortigate images.
# variable "enable_secure_boot" {
#   default     = false
#   description = "Not available for FortiGate images. Secure Boot is a security feature that ensures only trusted software is loaded during the boot process, helping to protect against rootkits and other malicious software."
#   type        = bool
# }

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

# variable "disable_passwd_auth" {
#   default     = false
#   description = "[OPTIONAL] Flag to enable password authentication."
#   type        = bool  
# }

variable "fgtvm_custom_data" {
  description = "Provide a fortigate bootstrap script."
  type        = string
  default     = null
}

variable "license_type" {
  description = "License Type to create FortiGate VM. Values: byol or payg."
  type = string
  default = "payg"
}

variable "license_format" {
  description = "BYOL License format to create FortiGate VM. Values: token or file. Token available from 7.2.x image versions"
  default = "token"
}

variable "publisher" {
  description = "Publisher of the VM Image"
  type    = string
  default = "fortinet"
}

variable "fgtoffer" {
  description = "Offer for the VM Image"
  type    = string
  default = "fortinet_fortigate-vm_v5"
}

variable "fgtsku" {
  description = "SKU"
  type = map(any)
  default = {
    x86 = {
      byol = "fortinet_fg-vm"
      payg = "fortinet_fg-vm_payg_2023"
    },
    arm = {
      byol = "fortinet_fg-vm_arm64"
      payg = "fortinet_fg-vm_payg_2023_arm64"
    }
  }
}

variable "fgtversion" {
  description = "FortiGate Image version"
  type    = string
  default = "7.0.14"
}

variable "arch" {
  description = "Instance architecture, either arm or x86"
  type = string
  default = "x86"
}

variable "accept_marketplace_agreement" {
  description = "To accept marketplace agreement for deployed FortiGate image."
  type = bool
  default = false
}