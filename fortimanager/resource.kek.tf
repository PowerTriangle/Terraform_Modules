# data "azurerm_key_vault" "cmk_kv" {
# #  count               = var.disable_cmkdiskencryption == true ? 0 : 1
#   name                = split("/", var.subscription_env_config["cmk_keyvault_id"])[8]
#   resource_group_name = split("/", var.subscription_env_config["cmk_keyvault_id"])[4]
# }

# resource "azurerm_key_vault_key" "cmk-panorama" {
#   # checkov:skip=CKV_AZURE_40:Key encryption expiration requested to be disabled as no rotation policy exists
# #  count = var.disable_cmkdiskencryption == true ? 0 : 1
#   key_vault_id = var.subscription_env_config["cmk_keyvault_id"]
# #   for_each     = var.enable_encryption_at_host ? var.disk_encryption_set : {}
# #   name         = "${each.key}-key"  
#   name         = "${var.vm_name}-cmk"
#   key_type     = "RSA-HSM"
#   key_size     = 4096
#   key_opts = [
#     "decrypt",
#     "encrypt",
#     "sign",
#     "unwrapKey",
#     "verify",
#     "wrapKey"
#   ]
# #   rotation_policy {
# #     automatic {
# #       time_before_expiry = "P8D"
# #     }
# #     expire_after         = "PT672H"
# #     notify_before_expiry = "PT671H"
# #   }  
# }
# #
# resource "azurerm_disk_encryption_set" "cmk-panorama-set" {
# #  count = var.disable_cmkdiskencryption == true ? 0 : 1
#   name                = "${var.vm_name}-cmk-set"
# #   for_each                  = var.enable_encryption_at_host ? var.disk_encryption_set : {}
# #   name                      = each.key  
#   location            = data.azurerm_key_vault.cmk_kv.location # module.layer2_resource_groups["general_purpose_key_vault"].resource_group_location
#   resource_group_name = split("/", var.subscription_env_config["cmk_keyvault_id"])[4]
# #  key_vault_key_id          = azurerm_key_vault_key.key_vault_key[each.key].versionless_id  
#   key_vault_key_id    = azurerm_key_vault_key.cmk-panorama.versionless_id
#   encryption_type = "EncryptionAtRestWithCustomerKey"
#   auto_key_rotation_enabled = true
#   identity {
#     type = "SystemAssigned"
#   }
# }


# resource "azurerm_key_vault_access_policy" "cmk-panorama-policy-disk" {
#  #   depends_on = [ azurerm_disk_encryption_set.cmk-panorama-set ]
#   key_vault_id = var.subscription_env_config["cmk_keyvault_id"]
#   tenant_id = azurerm_disk_encryption_set.cmk-panorama-set.identity[0].tenant_id
#   object_id = azurerm_disk_encryption_set.cmk-panorama-set.identity[0].principal_id
#   key_permissions = [
#    "Create",
#    "Delete",
#     "Get",
#     "WrapKey",
#     "UnwrapKey",
#     "Get",  
#     "Purge",
#     "Recover",
#     "Update",
#     "List",
#     "Decrypt",
#     "Sign",
#   ]
# }

# resource "azurerm_role_assignment" "pan-assignment-disk1" {
#     depends_on = [ azurerm_disk_encryption_set.cmk-panorama-set ]
# #  count = var.disable_cmkdiskencryption == true ? 0 : 1
#   scope                = var.subscription_env_config["cmk_keyvault_id"]
#   role_definition_name = "Key Vault Crypto Service Encryption User" # "Key Vault Crypto User" # "Key Vault Crypto Service Encryption User" "Key Vault Crypto Officer"
#   principal_id         = azurerm_disk_encryption_set.cmk-panorama-set.identity[0].principal_id
# }
# # resource "azurerm_key_vault_access_policy" "cmk-panorama-policy-user" {
# #   key_vault_id = azurerm_key_vault.kek_kv_pan.id

# #   tenant_id = data.azurerm_client_config.current.tenant_id
# #   object_id = data.azurerm_client_config.current.object_id

# #   key_permissions = [
# #     "Create",
# #     "Delete",
# #     "Get",
# #     "WrapKey",
# #     "UnwrapKey",     
# #     "Purge",
# #     "Recover",
# #     "Update",
# #     "List",
# #     "Decrypt",
# #     "Sign",
# #     "GetRotationPolicy",
# #   ]
# # }



# # resource "azurerm_role_assignment" "pan-assignment-disk2" {
# # #  count = var.disable_cmkdiskencryption == true ? 0 : 1
# #   scope                = var.subscription_env_config["cmk_keyvault_id"]
# #   role_definition_name =  "Key Vault Contributor"
# #   principal_id         = azurerm_disk_encryption_set.cmk-panorama-set.identity[0].principal_id
# # }

# resource "azurerm_role_assignment" "pan-assignment-disk3" {
# #  count = var.disable_cmkdiskencryption == true ? 0 : 1
#   scope                = var.subscription_env_config["cmk_keyvault_id"]
#   role_definition_name =  "Key Vault Administrator"
#   principal_id         = azurerm_disk_encryption_set.cmk-panorama-set.identity[0].principal_id
# }


# # data "azurerm_key_vault_secret" "storage_account_key" {
# #   count        = var.domain_join_settings.domain_name != null ? 1 : 0
# #   name         = "storage-account-key"
# #   key_vault_id = var.subscription_env_config["keyvault_id"]
# # }

# # data "azurerm_key_vault_secret" "domain_user_password" {
# #   count        = var.domain_join_settings.domain_name != null ? 1 : 0
# #   name         = "domain-user-password"
# #   key_vault_id = var.subscription_env_config["keyvault_id"]
# # }


# //-------------------------------------

# // Encryption at host access policy
# # resource "azurerm_key_vault_access_policy" "encryption_at_host_access_policy" {
# #   // Please do not change this functionality, it is a combination of the standard access policy and the encryption at host permissions with the ability to perform key rotation.
# #   // Object IDs should not be used within the code as its not user friendly, use UPN or SPN instead.
# #   // If pipeline SPN doesn't have read only access to read the object IDs then please raise it with M365 team.
# #   // Such access to SPNs has been preapproved by the EIS team. All the ALZ pipeline SPNs already have such access.
# #   // If you are using an SPN that does not have such access, chances are you are using a new SPN or legacy Avanade SPN.
# #   for_each = toset(concat(
# #     data.azuread_users.users_upns_encryption_at_host_access.object_ids,
# #     data.azuread_service_principals.spns_encryption_at_host_access.object_ids,
# #     data.azuread_groups.groups_encryption_at_host_access.object_ids,
# #     local.keyvault_encryption_at_host_access_policy_object_ids,
# #   ))

# # #   key_vault_id = azurerm_key_vault.key_vault.id
# # #   tenant_id    = data.azurerm_client_config.current.tenant_id
# #   key_vault_id = var.subscription_env_config["cmk_keyvault_id"]
# #   tenant_id = azurerm_disk_encryption_set.cmk-panorama-set.identity[0].tenant_id  
# #   object_id    = each.key

# #   //Encryption at host requires "WrapKey", "UnwrapKey" and enabling key rotation requires "Rotate", "SetRotationPolicy" in addition to general purpose key permissions in the policy above.
# #   key_permissions         = ["Get", "List", "Update", "Create", "Delete", "GetRotationPolicy", "Recover", "WrapKey", "UnwrapKey", "Rotate", "SetRotationPolicy"]
# #   secret_permissions      = ["Get", "List", "Set", "Delete", "Recover"]
# #   storage_permissions     = ["Get"]
# #   certificate_permissions = ["Get", "List", "Update", "Create", "Delete", "Recover", "Import"]
# # }

# # // Pipeline SPN access policy
# # resource "azurerm_key_vault_access_policy" "pipeline_spn" {
# #   count = (!var.disable_default_access_policies) && (!var.enable_rbac_authorization) ? 1 : 0

# #   key_vault_id = azurerm_key_vault.key_vault.id
# #   tenant_id    = data.azurerm_client_config.current.tenant_id
# #   object_id    = data.azurerm_client_config.current.object_id

# #   certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"]
# #   key_permissions         = var.enabled_for_disk_encryption || var.enable_encryption_at_host ? ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"] : ["Get", "List", "Backup", "Create", "Rotate", "GetRotationPolicy", "SetRotationPolicy", "Delete", "Update", "Purge", "Recover"]
# #   secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
# #   storage_permissions     = []
# # }

# locals {
# #   keyvault_name = var.keyvault_name != null ? var.keyvault_name : "${var.company_identifier}-${(var.location == "ukwest" ? "ukw" : "uks")}-${var.environment}-${var.data_classification}-kvt"
# #   sku_name      = coalesce(var.kv_sku, (var.enabled_for_disk_encryption || var.enable_encryption_at_host ? "premium" : "standard"))

# #   // Maps that will be used in the role definition resources
# #   spn_role_definitions = merge([
# #     for role_name, role in var.key_vault_rbac_access : {
# #       for spn in role.spns :
# #       "${role_name}/spn/${spn}" => {
# #         role_definition_name = replace(role_name, "_", " ")
# #         principal_id         = data.azuread_service_principal.spn[spn].object_id
# #       }
# #     }
# #   ]...)

# #   user_role_definitions = merge([
# #     for role_name, role in var.key_vault_rbac_access : {
# #       for user in role.users :
# #       "${role_name}/user/${user}" => {
# #         role_definition_name = replace(role_name, "_", " ")
# #         principal_id         = data.azuread_user.user[user].object_id
# #       }
# #     }
# #   ]...)

# #   group_role_definitions = merge([
# #     for role_name, role in var.key_vault_rbac_access : {
# #       for group in role.groups :
# #       "${role_name}/group/${group}" => {
# #         role_definition_name = replace(role_name, "_", " ")
# #         principal_id         = data.azuread_group.group[group].object_id
# #       }
# #     }
# #   ]...)

# #   keyvault_standard_access_policy_object_ids = [
# #     for oid in var.access_policy_for_key_vault_standard_access.oids : oid
# #   ]

#   keyvault_encryption_at_host_access_policy_object_ids = [
#     for oid in var.access_policy_for_key_vault_encryption_at_host_access.oids : oid
#   ]
# }

# // Encryption at host access
# data "azuread_users" "users_upns_encryption_at_host_access" {
#   user_principal_names = var.access_policy_for_key_vault_encryption_at_host_access.upn
# }

# data "azuread_service_principals" "spns_encryption_at_host_access" {
#   display_names = var.access_policy_for_key_vault_encryption_at_host_access.spn
# }

# data "azuread_groups" "groups_encryption_at_host_access" {
#   display_names = var.access_policy_for_key_vault_encryption_at_host_access.group
# }