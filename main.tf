# Configure the Azure provider


provider "azurerm" {
  features {}
}
provider "databricks" {
  # Configuration options
}

module "resource_group" {
  source                      = "./resourceGroup"
  azurerm_resource_group_name = var.azurerm_resource_group_name
  azurerm_location            = var.azurerm_location
}

module "databricks_workspace" {
  source                          = "./databricks"
  azurerm_resource_group_name     = module.resource_group.resource_group_name
  azurerm_location                = module.resource_group.resource_group_location
  azure_databricks_workspace_name = var.azuredb_workspace_name
  prefix                          = var.prefix
}

# module "unitycatalog" {
#   source                          = "./unitycatalog"
#   depends_on = [ module.databricks_workspace ]
#   azurerm_resource_group_name     = module.resource_group.resource_group_name
#   azurerm_location                = module.resource_group.resource_group_location
#   azure_databricks_workspace_name = var.azuredb_workspace_name
#   prefix                          = var.prefix
#   databricks_resource_id = module.databricks_workspace.azure_databricks_resource_id
#   databricks_workspace_workspace_id = module.databricks_workspace.databricks_workspace_id
#   databricks_workspace_workspace_url = module.databricks_workspace.databricks_workspace_host
# }