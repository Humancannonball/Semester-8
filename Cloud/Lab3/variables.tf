variable "location" {
  description = "The Azure region in which all resources will be created."
  type        = string
  default     = "swedencentral"
}

variable "resource_group_name" {
  description = "The name of the Resource Group."
  type        = string
  default     = "IaC_group"
}

variable "vm_name_prefix" {
  description = "Prefix for the Virtual Machine name."
  type        = string
  default     = "mark-iac"
}

variable "admin_username" {
  description = "Admin username for the Virtual Machine."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the Virtual Machine."
  type        = string
  default     = "P@ssw0rd123!"
  sensitive   = true
}
