locals {
  resource_regex            = "(?i)subscriptions/(.+)/resourceGroups/(.+)/providers/Microsoft.Databricks/workspaces/(.+)"
  subscription_id           = regex(local.resource_regex, var.databricks_resource_id)[0]
  resource_group            = regex(local.resource_regex, var.databricks_resource_id)[1]
  databricks_workspace_name = regex(local.resource_regex, var.databricks_resource_id)[2]
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  databricks_workspace_host = var.databricks_workspace_workspace_url
  databricks_workspace_id   = var.databricks_workspace_workspace_id
  prefix                    = replace(replace(lower(data.azurerm_resource_group.this.name), "rg", ""), "-", "")
}

data "azurerm_resource_group" "this" {
  name = local.resource_group
}

data "azurerm_client_config" "current" {
}

data "azurerm_databricks_workspace" "this" {
  name                = local.databricks_workspace_name
  resource_group_name = local.resource_group
}


resource "databricks_metastore" "metastore" {
  # provider      = databricks.accounts
  name          = "primary"
  force_destroy = true
  region        = var.azurerm_location
}

resource "databricks_metastore_assignment" "metastore_assignment" {
  # provider             = databricks.accounts
  workspace_id         = var.databricks_workspace_workspace_id
  metastore_id         = databricks_metastore.metastore.metastore_id
  default_catalog_name = "hive_metastore"
}

resource "azurerm_databricks_access_connector" "ext_access_connector" {
  name                = "ext-databricks-mi"
  resource_group_name = var.azurerm_resource_group_name
  location            = var.azurerm_location
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account" "ext_storage" {
  name                     = "${local.prefix}extstorage"
  resource_group_name      = var.azurerm_resource_group_name
  location                 = var.azurerm_location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true
}

resource "azurerm_storage_container" "ext_storage" {
  name                  = "${local.prefix}-ext"
  storage_account_name  = azurerm_storage_account.ext_storage.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "ext_storage" {
  scope                = azurerm_storage_account.ext_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.ext_access_connector.identity[0].principal_id
}

resource "databricks_storage_credential" "external" {
  name = azurerm_databricks_access_connector.ext_access_connector.name
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.ext_access_connector.id
  }
  comment = "Managed by TF"
  depends_on = [
    databricks_metastore_assignment.metastore_assignment
  ]
}

resource "databricks_grants" "external_creds" {
  storage_credential = databricks_storage_credential.external.id
  grant {
    principal  = "Data Engineers"
    privileges = ["CREATE_EXTERNAL_TABLE"]
  }
}

resource "databricks_external_location" "some" {
  name = "external"
  url = format("abfss://%s@%s.dfs.core.windows.net",
    azurerm_storage_container.ext_storage.name,
  azurerm_storage_account.ext_storage.name)

  credential_name = databricks_storage_credential.external.id
  comment         = "Managed by TF"
  depends_on = [
    databricks_metastore_assignment.metastore_assignment
  ]
}

resource "databricks_grants" "some" {
  external_location = databricks_external_location.some.id
  grant {
    principal  = "Data Engineers"
    privileges = ["CREATE_EXTERNAL_TABLE", "READ_FILES"]
  }
}

resource "databricks_catalog" "sandbox" {
  name = "sandbox"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net",
    azurerm_storage_container.ext_storage.name,
  azurerm_storage_account.ext_storage.name)
  comment = "this catalog is managed by terraform"
  properties = {
    purpose = "testing"
  }
  depends_on = [databricks_metastore_assignment.metastore_assignment]
}

resource "databricks_grants" "sandbox" {
  catalog = databricks_catalog.sandbox.name
  grant {
    principal  = "Data Scientists"
    privileges = ["USE_CATALOG", "CREATE"]
  }
  grant {
    principal  = "Data Engineers"
    privileges = ["USE_CATALOG"]
  }
}

resource "databricks_schema" "things" {
  catalog_name = databricks_catalog.sandbox.id
  name         = "things"
  comment      = "this database is managed by terraform"
  properties = {
    kind = "various"
  }
}

resource "databricks_grants" "things" {
  schema = databricks_schema.things.id
  grant {
    principal  = "Data Engineers"
    privileges = ["USE_SCHEMA"]
  }
}

# data "databricks_spark_version" "latest" {
# }
# data "databricks_node_type" "smallest" {
#   local_disk = true
# }

# resource "databricks_cluster" "unity_shared" {
#   # provider                = var.azure_databricks_workspace_name
#   cluster_name            = "Shared clusters"
#   spark_version           = data.databricks_spark_version.latest.id
#   node_type_id            = data.databricks_node_type.smallest.id
#   autotermination_minutes = 20
#   num_workers             = 1
#   azure_attributes {
#     availability = "SPOT"
#   }
#   data_security_mode = "USER_ISOLATION"
#   # need to wait until the metastore is assigned
#   depends_on = [
#     databricks_metastore_assignment.metastore_assignment
#   ]
# }

# resource "databricks_group" "dev" {
#   display_name = "dev-clusters"
# }

# resource "databricks_user" "nihar" {
#   user_name = "blitznihar@gmail.com"
# }

# resource "databricks_group_member" "devnihar" {
#   group_id  = databricks_group.dev.id
#   member_id = databricks_user.nihar.id
# }

# # data "databricks_group" "dev" {
# #   # provider     = var.azure_databricks_workspace_name
# #   display_name = "dev-clusters"
# # }

# data "databricks_user" "dev" {
#   # provider = var.azure_databricks_workspace_name
#   for_each = databricks_group.dev.members
#   user_id  = each.key
# }

# resource "databricks_cluster" "dev" {
#   for_each = data.databricks_user.dev
#   # provider                = var.azure_databricks_workspace_name
#   cluster_name            = "${each.value.display_name} unity cluster"
#   spark_version           = data.databricks_spark_version.latest.id
#   node_type_id            = data.databricks_node_type.smallest.id
#   autotermination_minutes = 10
#   num_workers             = 1
#   azure_attributes {
#     availability = "SPOT_WITH_FALLBACK_AZURE"
#   }
#   data_security_mode = "SINGLE_USER"
#   single_user_name   = each.value.user_name
#   # need to wait until the metastore is assigned
#   depends_on = [
#     databricks_metastore_assignment.metastore_assignment
#   ]
# }

# resource "databricks_permissions" "dev_restart" {
#   for_each = data.databricks_user.dev
#   # provider   = var.azure_databricks_workspace_name
#   cluster_id = databricks_cluster.dev[each.key].cluster_id
#   access_control {
#     user_name        = each.value.user_name
#     permission_level = "CAN_RESTART"
#   }
# }