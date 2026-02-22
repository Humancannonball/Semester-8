output "resource_group_name" {
  description = "Name of the Azure Resource Group."
  value       = azurerm_resource_group.rg.name
}

output "web_app_name" {
  description = "Name of the Azure Web App."
  value       = azurerm_linux_web_app.app.name
}

output "web_url" {
  description = "URL to access the Azure Web App."
  value       = "https://${azurerm_linux_web_app.app.default_hostname}"
}

output "custom_domain_instructions" {
  description = "Instructions for adding a custom domain."
  value       = "1. Add a CNAME record in Cloudflare pointing 'name_paas.dclab.lt' to '${azurerm_linux_web_app.app.default_hostname}'.\n2. Add a TXT record with name 'asuid.name_paas.dclab.lt' and value '${azurerm_linux_web_app.app.custom_domain_verification_id}'.\n3. Go to Azure Portal -> your Web App -> Custom Domains and add the domain."
  sensitive   = true
}
