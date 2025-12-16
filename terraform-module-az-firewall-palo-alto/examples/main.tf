# module "firewall" {
#   # source = "git::ssh://git@github.com/edfenergy/terraform-module-az-firewall-palo-alto?ref=tags/0.0.1"
#   source = "../"

#   location                      = "UKSouth"
#   resource_group_name           = "test-rg"
#   prefix                        = "test-prefix"
#   internal_subnet_id            = "test-int-snet-01"
#   management_subnet_id          = "test-mgmt-snet-01"
#   load_balancer_private_ip      = "10.200.0.200"
#   storage_account_name          = "uniquelynamedsccount"
#   tags                          = {}
#   key_vault_name                = "pa-test"
#   key_vault_resource_group_name = "test-kv-rg"
#   username_secret_name          = "pa-username"
#   password_secret_name          = "pa-password"
#   panorama_ip_secret_name       = "pa-pan-ip"
#   authcode_secret_name          = "pa-auth-code"
#   vm_auth_key_secret_name       = "pa-vm-auth-key"
#   panorama_template_stack_name  = "test-stack"
#   panorama_device_group_name    = "test-device-group"
#   firewalls = {
#     "a" = { zone = 1 },
#     "b" = { zone = 2, img_sku = "byol", img_version = "9.1.13", vm_size = "Standard_D3_v2" }
#   }
# }