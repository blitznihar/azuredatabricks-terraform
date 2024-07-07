terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    random = {
      source = "hashicorp/random"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.111.0"
    }

  }

  # required_version = ">= 1.1.0"
}