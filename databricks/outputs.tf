output "databricks_workspace_host" {
  value = "https://${azurerm_databricks_workspace.databricks_workspace.workspace_url}/"
}

output "databricks_workspace_id" {
  value = azurerm_databricks_workspace.databricks_workspace.workspace_id
}

output "azure_databricks_resource_id" {
  value = azurerm_databricks_workspace.databricks_workspace.id
}