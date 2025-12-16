module "resource_group" {
  #checkov:skip=CKV_TF_1:"Ensure Terraform module sources use a commit hash"
  source                  = "git::ssh://git@github.com/edfenergy/terraform-module-az-resource-group.git?ref=tags/1.2.0"
  resource_group_name     = "test-vnet-rg"
  resource_group_location = "UKSouth"
}
