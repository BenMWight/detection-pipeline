terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  # State backend.
  #
  # Local state is the default and is acceptable here, but say so deliberately
  # in the README. Criterion 4 assesses whether state handling was a decision
  # rather than an accident.
  #
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = ""
  #   container_name       = "tfstate"
  #   key                  = "detection-pipeline.tfstate"
  # }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  # Authentication comes from `az login` or ARM_* environment variables.
  # Do NOT put subscription_id, client_id, client_secret or tenant_id here.
}
