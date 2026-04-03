variable "location" {
  description = "The Azure region in which all resources will be created."
  type        = string
  default     = "swedencentral"
}

variable "resource_group_name" {
  description = "The name of the Resource Group."
  type        = string
  default     = "FaaS_group"
}

variable "function_app_name_prefix" {
  description = "Prefix used for the globally unique Function App name."
  type        = string
  default     = "mark-func"
}

variable "storage_account_name_prefix" {
  description = "Prefix used for the storage account name. Must contain only lowercase letters and numbers."
  type        = string
  default     = "markfunc"
}

variable "python_version" {
  description = "Python version for the Azure Function App."
  type        = string
  default     = "3.11"
}
