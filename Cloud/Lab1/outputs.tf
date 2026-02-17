output "resource_group_name" {
  description = "Name of the Azure Resource Group."
  value       = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  description = "Public IP address assigned to the VM."
  value       = azurerm_public_ip.pip.ip_address
}

output "dns_name" {
  description = "Fully qualified domain name of the Public IP."
  value       = azurerm_public_ip.pip.fqdn
}

output "vm_admin_username" {
  description = "Admin username for the VM."
  value       = var.admin_username
}

output "ssh_key_command" {
  description = "SSH command using the generated private key."
  value       = "ssh -i id_rsa ${var.admin_username}@${azurerm_public_ip.pip.fqdn}"
}

output "ssh_password_command" {
  description = "SSH command using password authentication."
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.pip.fqdn}"
}

output "web_url" {
  description = "URL to access the Nginx web page."
  value       = "http://${azurerm_public_ip.pip.fqdn}"
}
