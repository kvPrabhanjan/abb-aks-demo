terraform {
  required_version = ">= 1.0.0"    
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.113.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "=2.5.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "=3.6.1"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    cognitive_account {
      purge_soft_delete_on_destroy = true
    }

    key_vault {
      purge_soft_delete_on_destroy = true
    }

    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
  }
}

# data "http" "ifconfig" {
#   url = "http://ifconfig.me"
# }

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "aks-store" {
  name     = "rg-${var.resource_group_name_suffix}"
  location = var.location
}

# terraform {
#  backend "azurerm" {
#    resource_group_name  = "rg-aks-store"
#    storage_account_name = "aksstoretf"
#    container_name       = "tfstate"
#    key                  = "prod.terraform.tfstate"
#  }
#}

resource "azurerm_storage_account" "tfstate" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.aks-store.name
  location                 = azurerm_resource_group.aks-store.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = {
    environment = "terraform-backend"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

data "http" "ifconfig" {
  url = "http://ifconfig.me"
}
