output "resource_group_name" {
  description = "Name of the Azure Resource Group."
  value       = azurerm_resource_group.rg.name
}

output "vm_name" {
  description = "Name of the Virtual Machine."
  value       = azurerm_linux_virtual_machine.vm.name
}

output "public_ip_address" {
  description = "Public IP address of the Virtual Machine."
  value       = azurerm_public_ip.public_ip.ip_address
}

output "admin_username" {
  description = "Admin username for SSH access."
  value       = var.admin_username
}

output "ssh_command" {
  description = "SSH command to connect to the VM."
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.public_ip.ip_address}"
}
