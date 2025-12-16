# module "vnet" {
#   #checkov:skip=CKV_TF_1:"Ensure Terraform module sources use a commit hash"
#   source               = ""
#   resource_group_name  = module.key_vault_resource_group.resource_group_name
#   location             = module.key_vault_resource_group.resource_group_location
#   virtual_network_name = "${var.env}-vnet-${var.suffix}"
#   address_space        = ["172.16.1.0/24"]
#   subnets = {
#     pep = {
#       address_prefixes = ["172.16.1.0/25"]
#     }
#   }
# }
