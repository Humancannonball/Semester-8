variable "site_a_location" {
  description = "Azure region for site A."
  type        = string
  default     = "swedencentral"
}

variable "site_b_location" {
  description = "Azure region for site B."
  type        = string
  default     = "italynorth"
}

variable "site_a_resource_group_name" {
  description = "Resource group name for site A."
  type        = string
  default     = "VPN_site_a_group_lab6"
}

variable "site_b_resource_group_name" {
  description = "Resource group name for site B."
  type        = string
  default     = "VPN_site_b_group_lab6"
}

variable "site_a_address_space" {
  description = "Address space for site A virtual network."
  type        = string
  default     = "10.60.0.0/16"
}

variable "site_b_address_space" {
  description = "Address space for site B virtual network."
  type        = string
  default     = "10.70.0.0/16"
}

variable "site_a_vm_subnet" {
  description = "VM subnet for site A."
  type        = string
  default     = "10.60.1.0/24"
}

variable "site_b_vm_subnet" {
  description = "VM subnet for site B."
  type        = string
  default     = "10.70.1.0/24"
}

variable "site_a_gateway_subnet" {
  description = "Gateway subnet for site A."
  type        = string
  default     = "10.60.255.0/27"
}

variable "site_b_gateway_subnet" {
  description = "Gateway subnet for site B."
  type        = string
  default     = "10.70.255.0/27"
}

variable "vpn_shared_key" {
  description = "Shared key used on both site-to-site connections."
  type        = string
  default     = "Mark-VPN-Lab6-SharedKey!"
  sensitive   = true
}

variable "admin_username" {
  description = "Admin username for both virtual machines."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for both virtual machines."
  type        = string
  default     = "Lab6-Azure-2026!"
  sensitive   = true
}

variable "vm_size" {
  description = "VM size for both Linux virtual machines."
  type        = string
  default     = "Standard_B1ms"
}

variable "vpn_gateway_sku" {
  description = "VPN gateway SKU supported by current Azure regions."
  type        = string
  default     = "VpnGw1AZ"
}
