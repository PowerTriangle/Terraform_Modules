variable "resource_group_name" {
  description = "Name of the Resource Group to use."
  type        = string
}

variable "location" {
  description = "The Azure region to use."
  type        = string
  default     = "UKSouth"
}

variable "zones" {
  description = "Load Balancer Availability Zone span."
  type        = list(number)
  default     = [1, 2, 3]
}

variable "firewalls" {
  description = <<-EOF
  Map of virtual machines to create. Each firewall object key is used in resource names and must be unique.
  Each firewall object has the following keys:
  - zone (AZ in which to place VM)
  - img_sku
  - img_version
  - vm_size
  - managed_disk_type
  - enable_backend_pool
  EOF
  type = map(
    object({
      zone                = number
      img_sku             = optional(string)
      img_version         = optional(string)
      vm_size             = optional(string)
      managed_disk_type   = optional(string)
      enable_backend_pool = optional(bool)
    })
  )
  default = {
    a = {
      zone = 1
    },
    b = {
      zone = 2
    }
  }
}

variable "internal_subnet_id" {
  description = "The firewall internal subnet ID."
  type        = string
}

variable "management_subnet_id" {
  description = "The firewall management subnet ID."
  type        = string
}

variable "load_balancer_private_ip" {
  description = "The private IP address to assign to the internal load balancer. This IP **must** fall in the internal subnet."
  type        = string
}

variable "storage_account_name" {
  description = "Default name of the storage account to create. The name must be unique across Azure. Required if enable bootstrap is true"
  type        = string
  default     = null
}

variable "key_vault_id" {
  description = "The ID of the Azure Key Vault instance where the firewall secrets are stored."
  type        = string
}

variable "username_secret_name" {
  description = "The Key Vault secret name where the firewall admin username is stored. Required if use_existing_secrets is true."
  type        = string
  default     = null
}

variable "password_secret_name" {
  description = "The Key Vault secret name where the firewall admin password is stored. Required if use_existing_secrets is true."
  type        = string
  default     = null
}

variable "panorama_ip_secret_name" {
  description = "The Key Vault secret name where the panorama IP address is stored. Required if enable bootstrap is true."
  type        = string
  default     = null
}

variable "authcode_secret_name" {
  description = "The Key Vault secret name where the Palo Alto license authorisation code is stored. Required if enable bootstrap is true."
  type        = string
  default     = null
}

variable "vm_auth_key_secret_name" {
  description = "The Key Vault secret name where the Panorama VM Authorisation key is stored. Required if enable bootstrap is true."
  type        = string
  default     = null
}

variable "panorama_template_stack_name" {
  description = "The Panorama template stack to assign the firewalls. Required if enable bootstrap is true."
  type        = string
  default     = null
}

variable "panorama_device_group_name" {
  description = "The Panorama device group to assign the firewalls. Required if enable bootstrap is true."
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to assign to the resources created."
  type        = map(string)
  default     = {}
}

variable "default_img_sku" {
  description = "VM-Series SKU - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  type        = string
  default     = "byol"
}

variable "default_img_version" {
  description = "VM-Series PAN-OS version - list available with `az vm image list -o table --all --publisher paloaltonetworks`"
  type        = string
  default     = "9.1.13"
}

variable "default_vm_size" {
  description = "Azure VM size (type) to be created."
  type        = string
  default     = "Standard_DS4_v2"
}

variable "default_managed_disk_type" {
  description = "Type of OS Managed Disk to create for the virtual machine. Possible values are `Standard_LRS`, `StandardSSD_LRS` or `Premium_LRS`. The `Premium_LRS` works only for selected `vm_size` values, details in Azure docs."
  default     = "Premium_LRS"
  type        = string
}

variable "default_enable_backend_pool" {
  description = "Whether to associate the VM private interfaces with the specified load balancer backend pool."
  type        = string
  default     = true
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "enable_bootstrap" {
  description = "bool value to whether to enable firewall bootstrap for module"
  type        = bool
  default     = true
}

variable "enable_marketplace_agreement" {
  description = "bool value to whether to enable firewall image marketplace agreement"
  type = bool
  default = true
}

variable "use_existing_secrets" {
  description = "bool value to determine whether to use existing stored secrets from keyvault"
  type = bool
  default = true
}

variable "img_offer" {
  description = "paloalto firewall image offer"
  type        = string
  default     = "vmseries-flex"
}

variable "img_plan" {
  description = "paloalto firewall image plan"
  type        = string
  default     = "byol"
}

variable "vm_username" {
  description = "paloalto firewall username"
  type        = string
  default     = null
}

variable "vm_password" {
  description = "paloalto firewall password"
  type        = string
  sensitive   = true
  default     = null
}

variable "diagnostics_storage_uri" {
  description = "VM diagnostics uri for when enable bootstrap is false, default to null to use managed storage account"
  type        = string
  default     = null
}