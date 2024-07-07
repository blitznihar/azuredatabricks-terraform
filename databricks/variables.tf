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

variable "databricks_sku" {
  type        = string
  description = "sku"
  default     = "premium"
}

variable "prefix" {
  type        = string
  description = "prefix name"
}