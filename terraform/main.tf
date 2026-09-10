# Phase 4 deliverable.
#
# This file is intentionally near-empty. Building it out is the assessed work:
#   - Log Analytics workspace with Sentinel enabled
#   - your three detections as azurerm_sentinel_alert_rule_scheduled resources,
#     with query, frequency, period, severity and ATT&CK tactics driven from the
#     Sigma rule metadata rather than hardcoded here
#
# Leave the ingestion cap on. An unbounded workspace is how this project
# quietly eats your Azure credit.

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.workspace_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  daily_quota_gb      = var.daily_quota_gb
  tags                = var.tags
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "this" {
  workspace_id = azurerm_log_analytics_workspace.this.id
}

resource "azurerm_sentinel_alert_rule_scheduled" "illicit_consent" {
  name                       = "unverified-app-registration"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  display_name               = "Application registered with unverified publisher domain"
  severity                   = "Medium"
  query                      = <<-QUERY
    AuditLogs
    | where OperationName =~ "Add application" and Result =~ "success"
    | where TargetResources contains "PublisherDomain"
    | where TargetResources contains ".onmicrosoft.com"
  QUERY
  query_frequency            = "PT1H"
  query_period               = "PT1H"
  tactics                    = ["CredentialAccess"]

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.this]
}

resource "azurerm_sentinel_alert_rule_scheduled" "password_spray" {
  name                       = "entra-password-spray"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  display_name               = "Entra password spraying"
  severity                   = "Medium"
  query                      = <<-QUERY
    SigninLogs
    | where ResultType == "50126"
    | summarize
        FailedAttempts = count(),
        TargetedAccounts = dcount(UserPrincipalName),
        Accounts = make_set(UserPrincipalName, 20)
      by IPAddress, bin(TimeGenerated, 30m)
    | where TargetedAccounts >= 10
  QUERY
  query_frequency            = "PT30M"
  query_period               = "PT1H"
  tactics                    = ["CredentialAccess"]

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.this]
}

resource "azurerm_sentinel_alert_rule_scheduled" "role_assignment_afterhours" {
  name                       = "role-assignment-outside-hours"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  display_name               = "Role assignment outside business hours"
  severity                   = "Low"
  query                      = <<-QUERY
    AzureActivity
    | where OperationNameValue =~ "MICROSOFT.AUTHORIZATION/ROLEASSIGNMENTS/WRITE"
    | where ActivityStatusValue =~ "Success"
    | extend LocalHour = datetime_part("Hour", datetime_add("Hour", 10, TimeGenerated))
    | where LocalHour < 8 or LocalHour >= 18
  QUERY
  query_frequency            = "PT1H"
  query_period               = "PT1H"
  tactics                    = ["Persistence"]

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.this]
}