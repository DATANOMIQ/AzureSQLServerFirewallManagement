terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">2.60"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }

  subscription_id = var.az_subscription_id
}

/*
 * Variables
 *
 * Definition of relevant variables to run this Terraform module. Variables need to be 
 * specified in a terraform.tfvars file
 */
variable "az_location" {
  type    = string
  default = "westeurope"
}

variable "az_subscription_id" {
  type      = string
  sensitive = true
}

data "azurerm_subscription" "primary" {
}

// create azure automation account
resource "azurerm_automation_account" "az-management-automation" {
  name                = "az-management-account"
  location            = var.az_location
  resource_group_name = azurerm_resource_group.rg-management.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }
  tags = {
    environment = "development"
  }
}

// make the automation account contributer on subscription level
resource "azurerm_role_assignment" "automation-accont" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.az-management-automation.identity[0].principal_id
}

// add powershell script
resource "azurerm_automation_runbook" "SQL_server_firewall_management" {
  name                    = "Daily-SQLServer-Firewall-Cleanup"
  location                = var.az_location
  resource_group_name     = azurerm_resource_group.rg-management.name
  automation_account_name = azurerm_automation_account.az-management-automation.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This runbook removes all autocreated firewall rules from all logical SQL servers in this subscription"
  runbook_type            = "PowerShellWorkflow"

  publish_content_link {
    uri = "https://raw.githubusercontent.com/DATANOMIQ/AzureSQLServerFirewallManagement/main/powershell/removeAllFirewallRules.ps1"
  }
}

// create the daily schedule
resource "azurerm_automation_schedule" "daily-midnight" {
  name                    = "daily-automation-schedule"
  resource_group_name     = azurerm_resource_group.rg-management.name
  automation_account_name = azurerm_automation_account.az-management-automation.name
  frequency               = "Day"
  interval                = 1
  start_time              = timeadd(timestamp(), "10m")
  description             = "Run daily"

  lifecycle {
    // do not update the auto created start time. If change to start_time is needed, remove start_time from ignore_changes
    ignore_changes = [
      start_time
    ]
  }
}

// link runbook and schedule
resource "azurerm_automation_job_schedule" "daily-firewall-cleanup" {
  resource_group_name     = azurerm_resource_group.rg-management.name
  automation_account_name = azurerm_automation_account.az-management-automation.name
  runbook_name            = azurerm_automation_runbook.SQL_server_firewall_management.name
  schedule_name           = azurerm_automation_schedule.daily-midnight.name
}
