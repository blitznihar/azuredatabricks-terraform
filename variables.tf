variable "azurerm_resource_group_name" {
  type        = string
  description = "Name of the Resource Group"
  default     = "blitzdbrg"
}

variable "azurerm_location" {
  type        = string
  description = "Azure Location"
  default     = "eastus2"
}

variable "azuredb_workspace_name" {
  type        = string
  description = "Azure Databricks Name"
  default     = "blitzdatabricks"

}

variable "prefix" {
  type        = string
  description = "Azure Databricks Name"
  default     = "blitz"

}