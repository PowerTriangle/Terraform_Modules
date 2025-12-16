locals {
  keyvault_name = var.keyvault_name != null ? var.keyvault_name : "${var.company_identifier}-${(var.location == "ukwest" ? "ukw" : "uks")}-${var.environment}-${var.data_classification}-kvt"
  sku_name      = coalesce(var.kv_sku, (var.enabled_for_disk_encryption || var.enable_encryption_at_host ? "premium" : "standard"))

  // Maps that will be used in the role definition resources
  spn_role_definitions = merge([
    for role_name, role in var.key_vault_rbac_access : {
      for spn in role.spns :
      "${role_name}/spn/${spn}" => {
        role_definition_name = replace(role_name, "_", " ")
        principal_id         = data.azuread_service_principal.spn[spn].object_id
      }
    }
  ]...)

  user_role_definitions = merge([
    for role_name, role in var.key_vault_rbac_access : {
      for user in role.users :
      "${role_name}/user/${user}" => {
        role_definition_name = replace(role_name, "_", " ")
        principal_id         = data.azuread_user.user[user].object_id
      }
    }
  ]...)

  group_role_definitions = merge([
    for role_name, role in var.key_vault_rbac_access : {
      for group in role.groups :
      "${role_name}/group/${group}" => {
        role_definition_name = replace(role_name, "_", " ")
        principal_id         = data.azuread_group.group[group].object_id
      }
    }
  ]...)

  keyvault_standard_access_policy_object_ids = [
    for oid in var.access_policy_for_key_vault_standard_access.oids : oid
  ]

  keyvault_encryption_at_host_access_policy_object_ids = [
    for oid in var.access_policy_for_key_vault_encryption_at_host_access.oids : oid
  ]
}
