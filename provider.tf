terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
  
  subscription_id = "f651a542-4390-4c89-a568-5a359fa1d9e8"
}