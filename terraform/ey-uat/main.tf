provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=1.28.0"
  subscription_id  = "41efa386-17bf-4afd-b0b0-3e3db6e194cb"
  tenant_id      = "04445358-4583-495e-ac0a-34105448c569"
  client_id = "${var.client_id}"
  client_secret = "${var.client_secret}"
}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.resource_group}"
  location = "${var.location}"
  tags = {
     environment = "${var.environment}"
  }
}

module "kubernetes" {
  source = "../modules/kubernetes/azure"
  environment = "${var.environment}"
  name = "ey-uat"
  location = "${azurerm_resource_group.resource_group.location}"
  resource_group = "${azurerm_resource_group.resource_group.name}"
  client_id = "${var.client_id}"
  client_secret = "${var.client_secret}"
  nodes = "4"
}

module "zookeeper" {
  source = "../modules/storage/azure"
  environment = "${var.environment}"
  itemCount = "3"
  disk_prefix = "zookeeper"
  location = "${azurerm_resource_group.resource_group.location}"
  resource_group = "${module.kubernetes.node_resource_group}"
  storage_sku = "Standard_LRS"
  disk_size_gb = "5"

}

module "kafka" {
  source = "../modules/storage/azure"
  environment = "${var.environment}"
  itemCount = "3"
  disk_prefix = "kafka"
  location = "${azurerm_resource_group.resource_group.location}"
  resource_group = "${module.kubernetes.node_resource_group}"
  storage_sku = "Standard_LRS"
  disk_size_gb = "50"

}
module "es-master" {
  source = "../modules/storage/azure"
  environment = "${var.environment}"
  itemCount = "3"
  disk_prefix = "es-master"
  location = "${azurerm_resource_group.resource_group.location}"
  resource_group = "${module.kubernetes.node_resource_group}"
  storage_sku = "Standard_LRS"
  disk_size_gb = "2"

}
module "es-data-v1" {
  source = "../modules/storage/azure"
  environment = "${var.environment}"
  itemCount = "2"
  disk_prefix = "es-data-v1"
  location = "${azurerm_resource_group.resource_group.location}"
  resource_group = "${module.kubernetes.node_resource_group}"
  storage_sku = "Standard_LRS"
  disk_size_gb = "50"

}

module "postgres-db" {
  source = "../modules/db/azure"
  server_name = "ey-uat-db"
  resource_group = "${module.kubernetes.node_resource_group}"
  sku_cores = "2"
  location = "${azurerm_resource_group.resource_group.location}"
  sku_tier = "Basic"
  storage_mb = "51200"
  backup_retention_days = "7"
  administrator_login = "eyuat"
  administrator_login_password = "${var.db_password}"
  ssl_enforce = "Disabled"
  db_name = "ey_uat_admin"
  environment= "${var.environment}"

}
