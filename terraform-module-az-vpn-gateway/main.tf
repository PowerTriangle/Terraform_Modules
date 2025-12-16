resource "azurerm_public_ip" "vpn_gateway" {
  name                = var.gateway_pip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  allocation_method   = "Static"
  zones               = var.zones
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                       = var.gateway_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  sku                        = var.gateway_sku
  type                       = "Vpn"
  vpn_type                   = "RouteBased"
  private_ip_address_enabled = true
  tags                       = var.tags
  ip_configuration {
    name                 = var.gateway_ip_config_name
    public_ip_address_id = azurerm_public_ip.vpn_gateway.id
    subnet_id            = var.gateway_subnet_id
  }
}

resource "azurerm_local_network_gateway" "vpn" {
  for_each            = { for connection in var.vpn_connections : connection.local_network_gateway_name => connection }
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = each.value.remote_address_space
  gateway_address     = each.value.remote_gateway_address
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "vpn" {
  for_each                           = var.vpn_connections
  name                               = each.key
  location                           = var.location
  resource_group_name                = var.resource_group_name
  type                               = "IPsec"
  egress_nat_rule_ids                = each.value.egress_nat_rule_ids
  ingress_nat_rule_ids               = each.value.ingress_nat_rule_ids
  virtual_network_gateway_id         = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id           = azurerm_local_network_gateway.vpn[each.value.local_network_gateway_name].id
  shared_key                         = data.azurerm_key_vault_secret.shared_key[each.key].value
  dpd_timeout_seconds                = each.value.dpd_timeout_seconds
  use_policy_based_traffic_selectors = each.value.traffic_selector_policies != null ? true : false
  tags                               = var.tags
  ipsec_policy {
    dh_group         = each.value.dh_group
    ike_encryption   = each.value.ike_encryption
    ike_integrity    = each.value.ike_integrity
    ipsec_encryption = each.value.ipsec_encryption
    ipsec_integrity  = each.value.ipsec_integrity
    pfs_group        = each.value.pfs_group
  }
  dynamic "traffic_selector_policy" {
    for_each = each.value.traffic_selector_policies != null ? each.value.traffic_selector_policies : []
    content {
      local_address_cidrs  = traffic_selector_policy.value.local_address_cidrs
      remote_address_cidrs = traffic_selector_policy.value.remote_address_cidrs
    }
  }
}

resource "azurerm_virtual_network_gateway_nat_rule" "nat_rules" {
  for_each                   = var.nat_rules
  name                       = each.key
  resource_group_name        = var.resource_group_name
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway.id
  mode                       = each.value.nat_mode
  type                       = each.value.nat_type

  external_mapping {
    address_space = each.value.external_mapping_subnet
    port_range    = each.value.external_mapping_port_range
  }

  internal_mapping {
    address_space = each.value.internal_mapping_subnet
    port_range    = each.value.internal_mapping_port_range
  }
}