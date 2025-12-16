variable "availability_zone" {
  default     = null
  description = "Azure Availability Zone for VM and disks."
  type        = number
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
      length(var.vm_name) < 65
    )
    error_message = "VM Name must be 64 characters or less."
  }
}

variable "vm_osdisk_size_gb" {
  description = "Size of OS disk to be deployed."
  type        = number
}

variable "vm_osdisk_name" {
  description = "OS Disk Name for the virtual machine."
  type        = string
  default     = null
}

variable "storage_account_type" {
  description = "Disk type used for OS disk."
  type        = string
  default     = "Premium_ZRS"
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
  default     = false
}

variable "vm_size" {
  description = "FortiAuthenticator VM Size"
  type        = string
  default     = "Standard_D2as_v4"

}

variable "data_disks" {
  default     = {}
  description = "[OPTIONAL] Data disks to create or copy and attach."
  type        = map(any)
}

variable "enable_encryption_at_host" {
  default     = true
  description = "all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host"
  type        = bool
}

variable "disk_encryption_set_id" {
  description = "The Disk Encryption Set resource id."
  type        = string
  default     = null
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
    name                          = optional(string)
    enable_accelerated_networking = optional(bool)
    enable_ip_forwarding          = optional(bool)
    ip_configurations = optional(map(object({
      subnet_id                     = string
      private_ip_address            = string
      private_ip_address_allocation = string
    })))
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
  default     = "SystemAssigned"
  description = "[OPTIONAL] Specifies the type of managed service identity for the VM."
  type        = string
  validation {
    condition     = (var.identity_type == null || can(regex("^$|^SystemAssigned$|^UserAssigned$|^SystemAssigned, UserAssigned$", var.identity_type)))
    error_message = "Error: identity_type does match one of the following 'SystemAssigned' 'UserAssigned' or 'SystemAssigned, UserAssigned'."
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
  description = "[OPTIONAL] Specifies password for the VM. Shouldn't be used for production"
  type        = string
}

# variable "disable_passwd_auth" {
#   default     = false
#   description = "[OPTIONAL] Flag to enable password authentication."
#   type        = bool  
# }

variable "vm_custom_data" {
  type        = string
  default     = null
  description = "(Optional) The Base64-Encoded Custom Data which should be used for this Virtual Machine. Changing this forces a new resource to be created."

  validation {
    condition     = var.vm_custom_data == null ? true : can(base64decode(var.vm_custom_data))
    error_message = "The `vm_custom_data` must be either `null` or a valid Base64-Encoded string."
  }
}


variable "image" {
  description = <<-EOF
  Basic Azure VM configuration.

  Following properties are available:

  - `version`                 - (`string`, optional, defaults to `6.0.2`) Fortinet FortiOS version; list available with 
                                `az vm image list --publisher fortinet --offer fortiauthenticator --all --output table` command.
  - `publisher`               - (`string`, optional, defaults to `fortinet`) the Azure Publisher identifier for an image
                                which should be deployed.
  - `offer`                   - (`string`, optional, defaults to `fortinet-fortiauthenticator-vm`) the Azure Offer identifier corresponding to a
                                published image.
  - `sku`                     - (`string`, optional, defaults to `fortinet-fac-vm`) Fortinet fortiauthenticator SKU; list available with
                                `az vm image list --publisher Fortinet --offer fortinet-fortiauthenticator --all --out table` command.
  - `enable_marketplace_plan` - (`bool`, optional, defaults to `true`) when set to `true` accepts the license for an offer/plan
                                on Azure Marketplace.
  - `custom_id`               - (`string`, optional, defaults to `null`) absolute ID of your own custom PAN-OS image to be used
                                for creating new Virtual Machines.

  **Important!** \
  The `custom_id` and `version` properties are mutually exclusive.
  EOF
  type = object({
    version                 = string
    publisher               = string
    offer                   = string
    sku                     = string
    enable_marketplace_plan = bool
    custom_id               = optional(string)
  })

  default = {
    version                 = "6.0.2"
    publisher               = "fortinet"
    offer                   = "fortinet-fortiauthenticator-vm"
    sku                     = "fortinet-fac-vm"
    enable_marketplace_plan = true
    custom_id               = null
  }

  validation { # version & custom_id
    condition = (var.image.custom_id != null && var.image.version == null
    ) || (var.image.custom_id == null && var.image.version != null)
    error_message = "Either `custom_id` or `version` has to be defined."

  }
}

variable "allow_extension_operations" {
  description = "This variable value determines whether to allow extension operations for the VM."
  type        = bool
  default     = false
}

variable "secrets_already_exist" {
  description = "This variable value determines whether to create new secrets for VM. Otherwise variables vm_username and vm_password have to be defined."
  type        = bool
  default     = false
}
