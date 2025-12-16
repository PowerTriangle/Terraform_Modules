module "network" {
  #checkov:skip=CKV_TF_1:Using tags for now, should be removed if a decision is made to use hashes.
  source               = "git::ssh://git@github.com/edfenergy/terraform-module-az-network.git?ref=tags/1.2.0"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = "test-vnet-${var.suffix}"
  address_space        = ["172.16.1.0/24"]
  subnets = {
    "subnet1-${var.suffix}" = {
      address_prefixes          = ["172.16.1.0/25"]
      network_security_group_id = "subnet1-nsg-${var.suffix}"
    }
    "subnet2-${var.suffix}" = {
      address_prefixes = ["172.16.1.128/25"]
    }
  }
  network_security_groups = {
    "subnet1-nsg-${var.suffix}" = {
      rules = {
        "inbound-ssh-${var.suffix}" = {
          description                = "Allow inbound SSH traffic"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    }
  }
}
