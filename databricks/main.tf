resource "azurerm_databricks_workspace" "databricks_workspace" {
  name                        = var.azure_databricks_workspace_name
  resource_group_name         = var.azurerm_resource_group_name
  location                    = var.azurerm_location
  sku                         = var.databricks_sku
  managed_resource_group_name = "${var.azure_databricks_workspace_name}-workspace-rg"
}