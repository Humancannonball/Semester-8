variable "location" {
  description = "The Azure region in which all resources will be created."
  type        = string
  default     = "swedencentral"
}

variable "resource_group_name" {
  description = "The name of the Resource Group."
  type        = string
  default     = "PaaS_group"
}

variable "app_name_prefix" {
  description = "Prefix for the App Service name to ensure global uniqueness."
  type        = string
  default     = "mark-paas"
}
