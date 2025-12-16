locals {
  internal_lb_subnet_id = module.network.subnet_ids["subnet2-${var.suffix}"]
}

module "internal_http_load_balancer" {
  source                            = "../."
  name                              = "web-lb-${var.suffix}"
  resource_group_name               = module.resource_group.resource_group_name
  location                          = module.resource_group.resource_group_location
  network_security_group_name       = "subnet1-nsg-${var.suffix}"
  network_security_allow_source_ips = ["172.16.1.0/24"]
  backend_name                      = "webserver_vmss-${var.suffix}"
  probe_name                        = "webserver_probe-${var.suffix}"
  frontend_ips = {
    "internal-${var.suffix}" = {
      subnet_id = local.internal_lb_subnet_id
      in_rules = {
        HTTP = {
          name     = "HTTP"
          port     = 80
          protocol = "Tcp"
        }
        HTTPS = {
          name     = "HTTPS"
          port     = 443
          protocol = "Tcp"
        }
      }
    }
  }
  depends_on = [module.network]
}

module "public_sftp_load_balancer" {
  source              = "../."
  name                = "sftp-lb-${var.suffix}"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  backend_name        = "sftp_vmss-${var.suffix}"
  probes = {
    "sftp_probe-${var.suffix}" = {
      port = 22
    }
  }
  frontend_ips = {
    "test-pip-${var.suffix}" = {
      create_public_ip = true
      in_rules = {
        SFTP = {
          name     = "SFTP"
          port     = 22
          protocol = "Tcp"
          probe    = "sftp_probe-${var.suffix}"
        }
      }
      out_rules = {
        "outbound_tcp" = {
          protocol = "All"
        }
      }
    }
  }
}
