# Note: We are using the resource group module here as it includes code to add the resource group lock
# This will stop Terrascan from complaining. The resource lock is disabled by default.
module "resource_group" {
  #checkov:skip=CKV_TF_1:Using tags for now, should be removed if a decision is made to use hashes.
  source                  = "git::ssh://git@github.com/edfenergy/terraform-module-az-resource-group.git?ref=tags/1.2.0"
  resource_group_name     = "test-vnet-rg-${var.suffix}"
  resource_group_location = "UKSouth"
}
