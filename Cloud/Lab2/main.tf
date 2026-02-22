resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    ENV = "PaaS"
  }
}

resource "azurerm_service_plan" "asp" {
  name                = "asp-${var.app_name_prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1" # Free tier

  tags = {
    ENV = "PaaS"
  }
}

resource "azurerm_linux_web_app" "app" {
  name                = "${var.app_name_prefix}-${random_id.suffix.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = false # F1 tier doesn't support Always On

    application_stack {
      node_version = "20-lts"
    }
  }

  tags = {
    ENV = "PaaS"
  }
}
