variable "azurerm_resource_group_name" {
  type        = string
  description = "Name of the Resource Group"
}

variable "azurerm_location" {
  type        = string
  description = "Azure Location"
}

variable "azure_databricks_workspace_name" {
  type        = string
  description = "Azure Location"
}

variable "prefix" {
  type        = string
  description = "prefix name"
}

variable "databricks_resource_id" {
  description = "The Azure resource ID for the databricks workspace deployment."
}

variable "databricks_workspace_workspace_id" {
  description = "The Azure databricks workspace ID."

}

variable "databricks_workspace_workspace_url" {
  description = "The Azure databricks workspace ID."

}