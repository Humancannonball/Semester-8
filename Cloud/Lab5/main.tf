locals {
  function_source_hash = sha256(join("", [
    for file_name in sort(fileset("${path.module}/function_src", "**")) :
    filesha256("${path.module}/function_src/${file_name}")
  ]))
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    ENV = "FaaS"
  }
}

resource "azurerm_storage_account" "functions" {
  name                     = "${var.storage_account_name_prefix}${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = {
    ENV = "FaaS"
  }
}

resource "azurerm_service_plan" "plan" {
  name                = "${var.function_app_name_prefix}-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"

  tags = {
    ENV = "FaaS"
  }
}

resource "azurerm_application_insights" "insights" {
  name                = "${var.function_app_name_prefix}-ai-${random_id.suffix.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"

  tags = {
    ENV = "FaaS"
  }
}

resource "azurerm_linux_function_app" "app" {
  name                        = "${var.function_app_name_prefix}-${random_id.suffix.hex}"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  service_plan_id             = azurerm_service_plan.plan.id
  storage_account_name        = azurerm_storage_account.functions.name
  storage_account_access_key  = azurerm_storage_account.functions.primary_access_key
  functions_extension_version = "~4"
  https_only                  = true

  site_config {
    application_stack {
      python_version = var.python_version
    }

    application_insights_connection_string = azurerm_application_insights.insights.connection_string
    application_insights_key               = azurerm_application_insights.insights.instrumentation_key
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.insights.connection_string
    AzureWebJobsStorage                   = azurerm_storage_account.functions.primary_connection_string
    FUNCTIONS_WORKER_RUNTIME              = "python"
    WEBSITE_RUN_FROM_PACKAGE              = "1"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "FaaS"
  }
}

resource "terraform_data" "deploy_function_code" {
  triggers_replace = [
    local.function_source_hash,
    azurerm_linux_function_app.app.id,
  ]

  provisioner "local-exec" {
    working_dir = path.module
    command     = "${path.module}/scripts/deploy-function-code.sh ${azurerm_resource_group.rg.name} ${azurerm_linux_function_app.app.name}"
  }

  depends_on = [
    azurerm_linux_function_app.app,
  ]
}
