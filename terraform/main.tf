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

# TODO Phase 4: azurerm_log_analytics_workspace (wire up var.retention_days and var.daily_quota_gb)
# TODO Phase 4: azurerm_sentinel_log_analytics_workspace_onboarding
# TODO Phase 4: azurerm_sentinel_alert_rule_scheduled, one per detection
