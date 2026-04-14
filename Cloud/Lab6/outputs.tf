output "site_a_gateway_public_ip" {
  description = "Public IP address of site A VPN gateway."
  value       = azurerm_public_ip.site_a_gateway.ip_address
}

output "site_b_gateway_public_ip" {
  description = "Public IP address of site B VPN gateway."
  value       = azurerm_public_ip.site_b_gateway.ip_address
}

output "site_a_vm_private_ip" {
  description = "Private IP address of site A VM."
  value       = azurerm_network_interface.site_a_vm.private_ip_address
}

output "site_b_vm_private_ip" {
  description = "Private IP address of site B VM."
  value       = azurerm_network_interface.site_b_vm.private_ip_address
}

output "site_a_connection_name" {
  description = "Connection resource name for site A."
  value       = azurerm_virtual_network_gateway_connection.site_a_to_b.name
}

output "site_b_connection_name" {
  description = "Connection resource name for site B."
  value       = azurerm_virtual_network_gateway_connection.site_b_to_a.name
}
