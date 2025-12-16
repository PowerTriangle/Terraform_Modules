variable "resource_group_name" {
  type = string
}

variable "lb_name" {
  type = string
}

variable "lb_rules" {
  type = map(map(string))
}

data "azurerm_lb" "example" {
  name                = var.lb_name
  resource_group_name = var.resource_group_name
}

data "azurerm_lb_rule" "example" {
  for_each            = var.lb_rules
  name                = each.value.rulekey
  loadbalancer_id     = data.azurerm_lb.example.id
}
