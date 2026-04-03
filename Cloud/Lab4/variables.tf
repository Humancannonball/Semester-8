variable "location" {
  description = "The Azure region in which all resources will be created."
  type        = string
  default     = "swedencentral"
}

variable "resource_group_name" {
  description = "The name of the Resource Group."
  type        = string
  default     = "Containers_group"
}

variable "name_prefix" {
  description = "Prefix used for Azure resource names."
  type        = string
  default     = "mark-docker"
}

variable "vm_size" {
  description = "The Azure VM size."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM."
  type        = string
  sensitive   = true
}
