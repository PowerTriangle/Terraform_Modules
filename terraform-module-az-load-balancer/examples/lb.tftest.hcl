provider "azurerm" {
  features {}
}

run "setup" {
  module {
    source = "./setup"
  }
}

// Apply the example terraform resources, including all dependencies
run "apply" {
  variables {
    suffix = run.setup.suffix
  }
  module {
    source = "./"
  }
}


// Run validation tests for the Internal HTTP LB example
run "validate_internal_http_lb" {
  variables {
    resource_group_name = run.apply.resource_group_name
    lb_name             = run.apply.internal_http_lb_name
    lb_rules            = run.apply.internal_http_lb_fe_rules
  }

  module {
    source = "./validation"
  }

  // LB validation
  assert {
    condition     = data.azurerm_lb.example.location == "uksouth"
    error_message = "Internal Http LB created in wrong location"
  }
  assert {
    condition     = length(data.azurerm_lb.example.private_ip_addresses) == 1
    error_message = "Expected a single private IP address for the internal LB"
  }

  // FIP validation
  // We are expecting one FIP configuration for a public IP
  assert {
    condition     = length(data.azurerm_lb.example.frontend_ip_configuration) == 1
    error_message = "Unexpected number of frontend IP configurations"
  }
  // Validate FIP name, private IP address and subnet are as expected
  assert {
    condition = alltrue([
      (data.azurerm_lb.example.frontend_ip_configuration[0].name == keys(run.apply.internal_http_lb_fe_ips)[0]),
      (data.azurerm_lb.example.frontend_ip_configuration[0].private_ip_address == values(run.apply.internal_http_lb_fe_ips)[0]),
      (data.azurerm_lb.example.frontend_ip_configuration[0].subnet_id == values(run.apply.subnet_ids)[1]),
      (data.azurerm_lb.example.frontend_ip_configuration[0].public_ip_address_id == "")
    ])
    error_message = "Unexpected FIP configuration for the private HTTP LB"
  }

  // FIP Rule validation
  // We are expecting two FIP rules for the internal HTTP LB
  assert {
    condition     = length(data.azurerm_lb_rule.example) == 2
    error_message = "Unexpected number of FIP rules for the internal HTTP LB"
  }
  // Validate HTTP FIP rule properties, and FIP association are as expected
  assert {
    condition = alltrue([
      (data.azurerm_lb_rule.example[keys(run.apply.internal_http_lb_fe_rules)[0]].name == "HTTP"),
      (data.azurerm_lb_rule.example[keys(run.apply.internal_http_lb_fe_rules)[0]].backend_port == 80),
      (data.azurerm_lb_rule.example[keys(run.apply.internal_http_lb_fe_rules)[0]].frontend_port == 80),
      (data.azurerm_lb_rule.example[keys(run.apply.internal_http_lb_fe_rules)[0]].frontend_ip_configuration_name == keys(run.apply.internal_http_lb_fe_ips)[0]),
    ])
    error_message = "Unexpected HTTP rule configuration"
  }
  // Validate HTTPS FIP rule properties, and FIP association are as expected
  assert {
    condition = alltrue([
      (data.azurerm_lb_rule.example[keys(run.apply.internal_http_lb_fe_rules)[1]].name == "HTTPS"),
      (data.azurerm_lb_rule.example[keys(run.apply.internal_http_lb_fe_rules)[1]].backend_port == 443),
      (data.azurerm_lb_rule.example[keys(run.apply.internal_http_lb_fe_rules)[1]].frontend_port == 443),
      (data.azurerm_lb_rule.example[keys(run.apply.internal_http_lb_fe_rules)[1]].frontend_ip_configuration_name == keys(run.apply.internal_http_lb_fe_ips)[0]),
    ])
    error_message = "Unexpected HTTPS rule configuration"
  }

}


// Run validation tests for the Public SFTP LB example
run "validate_public_sftp_lb" {
  variables {
    resource_group_name = run.apply.resource_group_name
    lb_name             = run.apply.public_sftp_lb_name
    lb_rules            = run.apply.public_sftp_lb_fe_rules
  }

  module {
    source = "./validation"
  }

  // LB validation
  assert {
    condition = data.azurerm_lb.example.location == "uksouth"
    error_message = "Public SFTP LB created in wrong location"
  }
  assert {
    condition     = length(data.azurerm_lb.example.private_ip_addresses) == 0
    error_message = "Unexpected private IP address allocation for the public LB"
  }

  // FIP validation
  // We are expecting one FIP configuration for a public IP
  assert {
    condition     = length(data.azurerm_lb.example.frontend_ip_configuration) == 1
    error_message = "Unexpected number of frontend IP configurations"
  }
  // Validate FIP name and that it is public
  assert {
    condition = alltrue([
      (data.azurerm_lb.example.frontend_ip_configuration[0].name == keys(run.apply.public_sftp_lb_fe_ips)[0]),
      (data.azurerm_lb.example.frontend_ip_configuration[0].private_ip_address == ""),
      (data.azurerm_lb.example.frontend_ip_configuration[0].subnet_id == ""),
      (data.azurerm_lb.example.frontend_ip_configuration[0].public_ip_address_id != "")
    ])
    error_message = "Unexpected FIP configuration for the public SFTP LB"
  }

  // FIP Rule validation
  // We are expecting one FIP rule for the public SFTP LB
  assert {
    condition     = length(data.azurerm_lb_rule.example) == 1
    error_message = "Unexpected number of FIP rules for the public SFTP LB"
  }

  // Validate SFTP FIP rule properties, and FIP association are as expected
  assert {
    condition = alltrue([
      (data.azurerm_lb_rule.example[keys(run.apply.public_sftp_lb_fe_rules)[0]].name == "SFTP"),
      (data.azurerm_lb_rule.example[keys(run.apply.public_sftp_lb_fe_rules)[0]].backend_port == 22),
      (data.azurerm_lb_rule.example[keys(run.apply.public_sftp_lb_fe_rules)[0]].frontend_port == 22),
      (data.azurerm_lb_rule.example[keys(run.apply.public_sftp_lb_fe_rules)[0]].frontend_ip_configuration_name == keys(run.apply.public_sftp_lb_fe_ips)[0]),
    ])
    error_message = "Unexpected SFTP rule configuration"
  }

}
