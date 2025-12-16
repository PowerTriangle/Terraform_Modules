data "azurerm_client_config" "current" {}

// ADE backup access
data "azuread_service_principal" "azure_backup_spn" {
  count        = var.enabled_for_disk_encryption ? 1 : 0
  display_name = "Backup Management Service"
}

// Encryption at host access
data "azuread_users" "users_upns_encryption_at_host_access" {
  user_principal_names = var.access_policy_for_key_vault_encryption_at_host_access.upn
}

data "azuread_service_principals" "spns_encryption_at_host_access" {
  display_names = var.access_policy_for_key_vault_encryption_at_host_access.spn
}

data "azuread_groups" "groups_encryption_at_host_access" {
  display_names = var.access_policy_for_key_vault_encryption_at_host_access.group
}

// Standard access
data "azuread_users" "users_upns_standard_access" {
  user_principal_names = var.access_policy_for_key_vault_standard_access.upn
}

data "azuread_service_principals" "spns_standard_access" {
  display_names = var.access_policy_for_key_vault_standard_access.spn
}

data "azuread_groups" "groups_standard_access" {
  display_names = var.access_policy_for_key_vault_standard_access.group
}

// RBAC access
data "azuread_service_principal" "spn" {
  for_each     = toset(flatten([for role in var.key_vault_rbac_access : role.spns]))
  display_name = each.key
}

data "azuread_user" "user" {
  for_each            = toset(flatten([for role in var.key_vault_rbac_access : role.users]))
  user_principal_name = each.key
}

data "azuread_group" "group" {
  for_each     = toset(flatten([for role in var.key_vault_rbac_access : role.groups]))
  display_name = each.key
}
