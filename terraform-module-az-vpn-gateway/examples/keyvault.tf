module "key_vault" {
  #checkov:skip=CKV_TF_1:"Ensure Terraform module sources use a commit hash"
  source                  = "git::ssh://git@github.com/edfenergy/terraform-module-az-keyvault.git?ref=tags/1.0.3"
  resource_group_name     = module.resource_group.resource_group_name
  keyvault_name           = "test-kv"
  enable_private_endpoint = false
  access_policy_for_key_vault = {
    upn : []
    spn : []
  }
}
