terraform {
  backend "local" {
    path = "myTerraform.tfstate"
  }
}

provider azurerm {    
  tenant_id = "f5d48d43-4601-4c7b-a0eb-8840cc6ec5a6"
  subscription_id = "4fd37f12-d93d-490d-aff5-87172f34317d"
  features {}
}

resource azurerm_resource_group socratic_dev_rg {
  name      = "socratic-dev-rg"
  location  = "Central US"
}

resource azurerm_storage_account socratic_dev_storage {
  name                        = "socraticdevstorage"
  resource_group_name         = azurerm_resource_group.socratic_dev_rg.name
  location                    = azurerm_resource_group.socratic_dev_rg.location
  account_tier                = "Standard"
  account_replication_type    = "LRS"

  depends_on          = [
    azurerm_resource_group.socratic_dev_rg
  ]
}

resource azurerm_app_service_plan socratic_dev_service_plan {
  name                = "socratic-dev-azure-functions-service-plan"
  location            = azurerm_resource_group.socratic_dev_rg.location
  resource_group_name = azurerm_resource_group.socratic_dev_rg.name
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

  depends_on          = [
    azurerm_resource_group.socratic_dev_rg
  ]
}

resource azurerm_servicebus_namespace socratic_dev_sbs {
  name                = "socratic-dev-servicebus"
  location            = azurerm_resource_group.socratic_dev_rg.location
  resource_group_name = azurerm_resource_group.socratic_dev_rg.name
  sku                 = "standard"
  depends_on          = [
    azurerm_resource_group.socratic_dev_rg
  ]
}

resource azurerm_servicebus_topic socratic_topic {
  name                = "socratic-topic"
  resource_group_name = azurerm_resource_group.socratic_dev_rg.name
  namespace_name      = "socratic-dev-servicebus"
  enable_partitioning = false
  depends_on          = [
    azurerm_servicebus_namespace.socratic_dev_sbs
  ]
}

resource azurerm_servicebus_subscription socratic_subscription {
  name                = "socratic-sub"
  resource_group_name = azurerm_resource_group.socratic_dev_rg.name
  namespace_name      = "socratic-dev-servicebus"
  topic_name          = azurerm_servicebus_topic.socratic_topic.name
  max_delivery_count = 1
  depends_on          = [
    azurerm_servicebus_topic.socratic_topic
  ]
}

resource azurerm_app_configuration socratic_config {
  name                = "socratic-config"
  location            = azurerm_resource_group.socratic_dev_rg.location
  resource_group_name = azurerm_resource_group.socratic_dev_rg.name
  sku                 = "free"
}

resource azurerm_function_app socratic-dev-funcapp {
  name                        = "socraticdevfuncapp"
  location                    = azurerm_resource_group.socratic_dev_rg.location
  resource_group_name         = azurerm_resource_group.socratic_dev_rg.name
  app_service_plan_id         = azurerm_app_service_plan.socratic_dev_service_plan.id
  storage_account_name        = azurerm_storage_account.socratic_dev_storage.name
  storage_account_access_key  = azurerm_storage_account.socratic_dev_storage.primary_access_key

  app_settings = {
    "AzureWebJobsServiceBus"      = azurerm_servicebus_namespace.socratic_dev_sbs.default_primary_connection_string
    "AZURE_APPCONFIG_URL"         = azurerm_app_configuration.socratic_config.endpoint
    "FUNCTIONS_EXTENSION_VERSION" = "~3"
    "WEBSITE_RUN_FROM_PACKAGE"    = "1"
    "FUNCTIONS_WORKER_RUNTIME"    = "dotnet"
  }

  depends_on                  = [
    azurerm_app_configuration.socratic_config,
    azurerm_servicebus_namespace.socratic_dev_sbs
  ]
}

resource azurerm_role_assignment func_app_config_role {
  scope                 = azurerm_app_configuration.socratic_config.id
  role_definition_name  = "App Configuration Data Reader"
  principal_id          = azurerm_function_app.socratic-dev-funcapp.identity.0.principal_id
}