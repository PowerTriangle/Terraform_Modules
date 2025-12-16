module "vnet" {
  #checkov:skip=CKV_TF_1:"Ensure Terraform module sources use a commit hash"
  source               = "git::ssh://git@github.com/edfenergy/terraform-module-az-network.git?ref=tags/1.2.0"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = "test-vnet"
  address_space        = ["172.16.1.0/24"]
  role                 = "Transit virtual network"
  subnets = {
    GatewaySubnet = {
      address_prefixes = ["172.16.1.0/25"]
    }
  }
}
