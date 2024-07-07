output "resource_group_name" {
  description = "resource group name"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "resource group location"
  value       = azurerm_resource_group.rg.location
}

output "resource_group_id" {
  description = "resource group id"
  value       = azurerm_resource_group.rg.id
}
