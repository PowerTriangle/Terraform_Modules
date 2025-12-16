resource "azurerm_lb" "lb" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  tags                = var.tags

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ips_order != null ? var.frontend_ips_order : keys(var.frontend_ips)
    iterator = each
    content {
      name                          = each.value
      public_ip_address_id          = try(var.frontend_ips[each.value].create_public_ip, false) ? azurerm_public_ip.this[each.value].id : try(data.azurerm_public_ip.this[each.value].id, null)
      subnet_id                     = try(var.frontend_ips[each.value].subnet_id, null)
      private_ip_address_allocation = try(var.frontend_ips[each.value].private_ip_address, null) != null ? "Static" : null
      private_ip_address            = try(var.frontend_ips[each.value].private_ip_address, null)
      zones                         = try(var.frontend_ips[each.value].subnet_id, null) != null ? var.avzones : []
    }
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  name            = var.backend_name
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  count               = var.probe_name != null ? 1 : 0
  name                = var.probe_name
  loadbalancer_id     = azurerm_lb.lb.id
  port                = var.probe_port
  protocol            = var.probe_protocol
  interval_in_seconds = var.probe_interval_in_seconds
}

resource "azurerm_lb_probe" "probes" {
  for_each            = var.probes
  name                = each.key
  loadbalancer_id     = azurerm_lb.lb.id
  port                = each.value.port
  protocol            = each.value.protocol
  interval_in_seconds = each.value.interval_in_seconds
  number_of_probes    = each.value.number_of_probes
}

resource "azurerm_lb_rule" "in_rules" {
  for_each = local.in_rules

  name                     = coalesce(try(each.value.rule.name, null), each.key)
  loadbalancer_id          = azurerm_lb.lb.id
  probe_id                 = can(each.value.rule.probe) ? azurerm_lb_probe.probes[each.value.rule.probe].id : azurerm_lb_probe.probe[0].id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend.id]

  protocol                       = each.value.rule.protocol
  backend_port                   = coalesce(try(each.value.rule.backend_port, null), each.value.rule.port)
  frontend_ip_configuration_name = each.value.fipkey
  frontend_port                  = each.value.rule.port
  enable_floating_ip             = try(each.value.rule.floating_ip, true)
  disable_outbound_snat          = try(each.value.rule.disable_outbound_snat, null) != null ? each.value.rule.disable_outbound_snat : local.disable_outbound_snat
  load_distribution              = try(each.value.rule.session_persistence, null)
}

resource "azurerm_lb_outbound_rule" "out_rules" {
  for_each = local.out_rules

  name                    = coalesce(try(each.value.rule.name, null), each.key)
  loadbalancer_id         = azurerm_lb.lb.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend.id

  protocol                 = each.value.rule.protocol
  enable_tcp_reset         = each.value.rule.protocol != "Udp" ? try(each.value.rule.enable_tcp_reset, null) : null
  allocated_outbound_ports = try(each.value.rule.allocated_outbound_ports, null)
  idle_timeout_in_minutes  = each.value.rule.protocol != "Udp" ? try(each.value.rule.idle_timeout_in_minutes, null) : null

  frontend_ip_configuration {
    name = each.value.fipkey
  }
}
