output "resource_group_name" {
  description = "Name of the Azure Resource Group."
  value       = azurerm_resource_group.rg.name
}

output "function_app_name" {
  description = "Name of the Azure Function App."
  value       = azurerm_linux_function_app.app.name
}

output "function_app_hostname" {
  description = "Default hostname of the Azure Function App."
  value       = azurerm_linux_function_app.app.default_hostname
}

output "http_function_url" {
  description = "HTTP trigger endpoint."
  value       = "https://${azurerm_linux_function_app.app.default_hostname}/api/hello"
}

output "app_insights_name" {
  description = "Application Insights resource name."
  value       = azurerm_application_insights.insights.name
}

output "logs_hint" {
  description = "Hint for verifying the timer function."
  value       = "Open Application Insights '${azurerm_application_insights.insights.name}' or use Azure Monitor queries to confirm the timer trigger runs every minute."
}
