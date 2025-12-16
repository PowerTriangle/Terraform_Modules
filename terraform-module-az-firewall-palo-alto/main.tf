terraform {
  required_version = ">= 1.3.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.7"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

data "azurerm_key_vault_secret" "username" {
  count        = var.use_existing_secrets ? 1 : 0
  key_vault_id = var.key_vault_id
  name         = var.username_secret_name
}

data "azurerm_key_vault_secret" "password" {
  count        = var.use_existing_secrets ? 1 : 0
  key_vault_id = var.key_vault_id
  name         = var.password_secret_name
}

data "azurerm_key_vault_secret" "authcode" {
  count        = var.enable_bootstrap ? 1 : 0
  key_vault_id = var.key_vault_id
  name         = var.authcode_secret_name
}

data "azurerm_key_vault_secret" "panorama_ip" {
  count        = var.enable_bootstrap ? 1 : 0
  key_vault_id = var.key_vault_id
  name         = var.panorama_ip_secret_name
}

data "azurerm_key_vault_secret" "vm_auth_key" {
  count        = var.enable_bootstrap ? 1 : 0
  key_vault_id = var.key_vault_id
  name         = var.vm_auth_key_secret_name
}

resource "local_sensitive_file" "authcodes" {
    count = var.enable_bootstrap ? 1 : 0
  content = templatefile("${path.module}/templates/authcodes.tftpl", {
    authcode = data.azurerm_key_vault_secret.authcode[0].value
  })
  filename = "${path.module}/output/authcodes"
}

resource "local_sensitive_file" "init_cfg" {
  count   = var.enable_bootstrap ? 1 : 0
  content = templatefile("${path.module}/templates/init-cfg.txt.tftpl", {
    vm_auth_key                  = data.azurerm_key_vault_secret.vm_auth_key[0].value,
    panorama_ip                  = data.azurerm_key_vault_secret.panorama_ip[0].value,
    panorama_template_stack_name = var.panorama_template_stack_name,
    panorama_device_group_name   = var.panorama_device_group_name
  })
  filename = "${path.module}/output/init-cfg.txt"
}

resource "azurerm_marketplace_agreement" "palo_alto_byol" {
  count     = var.enable_marketplace_agreement ? 1 : 0
  publisher = "paloaltonetworks"
  offer     = var.img_offer 
  plan      = var.img_plan 
}

module "load_balancer" {
  #checkov:skip=CKV_TF_1:"Ensure Terraform module sources use a commit hash"
  source              = "../terraform-module-az-load-balancer"
  name                = "${var.prefix}-t2fw-int-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  enable_zones        = true
  avzones             = var.zones
  probe_name          = "lb-probe-ilb"
  probe_port          = 443
  backend_name        = "${var.prefix}-t2-ilb-be"
  frontend_ips = {
    "${var.prefix}-t2-ilb-fe" = {
      subnet_id                     = var.internal_subnet_id
      private_ip_address_allocation = "Static"
      private_ip_address            = var.load_balancer_private_ip
      zones                         = var.zones
      in_rules = {
        ha-ports = {
          name                    = "ha-ports"
          port                    = 0
          protocol                = "All"
          idle_timeout_in_minutes = 4
          session_persistence     = "SourceIP"
        }
      }
    }
  }
  tags = merge(
    var.tags,
    {
      Role = "Tier-2 Internal LB"
    }
  )
}

module "bootstrap" {
  #checkov:skip=CKV_TF_1:"Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV2_AZURE_18:We do not use the storage account resource in the bootstrap module, create_storage_account is set to false
  #checkov:skip=CKV2_AZURE_1:We do not use the storage account resource in the bootstrap module, create_storage_account is set to false
  #checkov:skip=CKV2_AZURE_33:We do not use the storage account resource in the bootstrap module, create_storage_account is set to false
  #checkov:skip=CKV_AZURE_190:We do not use the storage account resource in the bootstrap module, create_storage_account is set to false
  #checkov:skip=CKV_AZURE_33:We do not use the storage account resource in the bootstrap module, create_storage_account is set to false
  #checkov:skip=CKV_AZURE_59:We do not use the storage account resource in the bootstrap module, create_storage_account is set to false
  #checkov:skip=CKV_AZURE_206:We do not use the storage account resource in the bootstrap module, create_storage_account is set to false
  #checkov:skip=CKV2_AZURE_38:We do not use the storage account resource in the bootstrap module, create_storage_account is set to false
  #checkov:skip=CKV2_AZURE_40:Ensure storage account is not configured with Shared Key authorization
  #checkov:skip=CKV2_AZURE_41:Ensure storage account is configured with SAS expiration policy
  #checkov:skip=CKV2_AZURE_47:Ensure storage account is configured without blob anonymous access
  count                  = var.enable_bootstrap ? 1 : 0
  source                 = "git::ssh://git@github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules.git//modules/bootstrap?ref=tags/v1.0.5"
  location               = var.location
  create_storage_account = false
  resource_group_name    = var.resource_group_name
  name                   = var.storage_account_name
  storage_share_name     = "bootstrap"
  files = {
    (local_sensitive_file.authcodes[0].filename) = "license/authcodes"
    (local_sensitive_file.init_cfg[0].filename)  = "config/init-cfg.txt"
  }
  # files_md5 is required because files are created at apply time
  # https://github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules/blob/c8b4417b966f4ccf1ed118bcdd350b1d42fa3acb/modules/bootstrap/variables.tf#L52
  files_md5 = {
    (local_sensitive_file.authcodes[0].filename) = local_sensitive_file.authcodes[0].content_md5
    (local_sensitive_file.init_cfg[0].filename)  = local_sensitive_file.init_cfg[0].content_md5
  }
}

module "vmseries" {
  #checkov:skip=CKV_TF_1:"Ensure Terraform module sources use a commit hash"
  #checkov:skip=CKV_AZURE_118:Palo Alto private interfaces on internal subnet need to have IP forwarding enabled
  #checkov:skip=CKV_AZURE_1:Radius-based authentication to be configured once firewalls imported into Panorama
  #checkov:skip=CKV2_AZURE_10:Microsoft Antimalware is ONLY applicable to MS Windows VMs which we do not have https://github.com/bridgecrewio/checkov/issues/1549
  #checkov:skip=CKV2_AZURE_12:Centralised backup policy in place for all production VMs
  #checkov:skip=CKV_AZURE_119:Public IPs are not configured for the VM-Series interfaces
  #checkov:skip=CKV2_AZURE_39:Ensure Azure VM is not configured with public IP and serial console access
  source              = "git::ssh://git@github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules.git//modules/vmseries?ref=tags/v1.0.5"
  for_each            = var.firewalls
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "eituksalzt2fw${each.key}"
  avzone              = each.value.zone
  username            = var.use_existing_secrets ? data.azurerm_key_vault_secret.username[0].value : azurerm_key_vault_secret.username[0].value
  password            = var.use_existing_secrets ? data.azurerm_key_vault_secret.password[0].value : azurerm_key_vault_secret.password[0].value
  img_sku             = coalesce(each.value.img_sku, var.default_img_sku)
  img_version         = coalesce(each.value.img_version, var.default_img_version)
  vm_size             = coalesce(each.value.vm_size, var.default_vm_size)
  managed_disk_type   = coalesce(each.value.managed_disk_type, var.default_managed_disk_type)
  enable_zones        = true
  tags = merge(
    var.tags,
    {
      Role              = "Tier-2 Firewall",
      ScheduledShutdown = "No",
      StartupPriority   = "10"
    }
  )
  bootstrap_options = var.enable_bootstrap ? join(";",
    [
      "storage-account=${module.bootstrap.storage_account.name}",
      "access-key=${module.bootstrap.storage_account.primary_access_key}",
      "file-share=${module.bootstrap.storage_share.name}",
      "share-directory=None"
  ]) : ""
  interfaces = [
    {
      name                = "eituksalzt2fw${each.key}-mgmt"
      subnet_id           = var.management_subnet_id
      enable_backend_pool = false
    },
    {
      name                = "eituksalzt2fw${each.key}-int"
      subnet_id           = var.internal_subnet_id
      lb_backend_pool_id  = module.load_balancer.backend_pool_id
      enable_backend_pool = coalesce(each.value.enable_backend_pool, var.default_enable_backend_pool)
    },
  ]
  diagnostics_storage_uri = var.enable_bootstrap ? module.bootstrap.storage_account.primary_blob_endpoint : var.diagnostics_storage_uri
  depends_on              = [azurerm_marketplace_agreement.palo_alto_byol[0]]
}
