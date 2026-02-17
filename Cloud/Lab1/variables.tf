variable "location" {
  description = "The Azure region in which all resources will be created."
  type        = string
  default     = "swedencentral"
}

variable "resource_group_name" {
  description = "The name of the Resource Group."
  type        = string
  default     = "IaaS_group"
}

variable "vm_size" {
  description = "The size of the Virtual Machine (1 vCPU, 1 GB RAM)."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "The admin username for the VM."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "The admin password for SSH access to the VM."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 12
    error_message = "Password must be at least 12 characters (Azure requirement)."
  }
}

variable "domain_name_label" {
  description = "The DNS label for the Public IP. Must be globally unique."
  type        = string
  default     = "mark-iaas"
}
