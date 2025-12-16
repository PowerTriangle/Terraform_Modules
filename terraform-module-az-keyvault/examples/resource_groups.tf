# module "key_vault_resource_group" {
#   #checkov:skip=CKV_TF_1:"Ensure Terraform module sources use a commit hash"
#   source                  = ""
#   resource_group_name     = "${var.env}-keyvault-rg-${var.suffix}"
#   resource_group_location = "UKSouth"
# }

# module "des_resource_group_01" {
#   #checkov:skip=CKV_TF_1:"Ensure Terraform module sources use a commit hash"
#   source                  = ""
#   resource_group_name     = "${var.env}-des-rg-01-${var.suffix}"
#   resource_group_location = "UKSouth"
# }

# module "des_resource_group_02" {
#   #checkov:skip=CKV_TF_1:"Ensure Terraform module sources use a commit hash"
#   source                  = ""
#   resource_group_name     = "${var.env}-des-rg-02-${var.suffix}"
#   resource_group_location = "UKSouth"
# }
