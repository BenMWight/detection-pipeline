# Decisions and issues

Running log of choices made and problems hit. Written as they happened, not
reconstructed afterwards.

## Provider registration: skipped auto, registered manually

The azurerm provider tries to register roughly 60 resource provider namespaces
on every plan. On a subscription where the signed-in identity had no role
assignment this failed with 403 across all of them, which buried the real
problem (no permissions) under sixty lines of noise.

Set `skip_provider_registration = true` and registered only what the project
needs: `Microsoft.OperationalInsights`, `Microsoft.SecurityInsights`,
`microsoft.insights`.

**Consequence:** the Sentinel onboarding resource then failed with
`MissingSubscriptionRegistration` for `Microsoft.OperationsManagement`, a
namespace not obviously implied by the resource type
`azurerm_sentinel_log_analytics_workspace_onboarding`. Registered it and the
apply completed.

Opting out of auto-registration means you own the list, and the list is not
discoverable from the Terraform resource names. Worth it here to keep plans
fast and errors legible, but it moves a class of failure from plan time to
apply time.

## Azure identity

Initial subscription authenticated successfully but had no role assignment for
the signed-in account, so every write failed with 403 while `az account show`
looked entirely healthy. Valid authentication with zero authorisation is a
confusing failure mode because the CLI gives no hint.

Moved to a subscription where the account holds Owner at subscription scope.

## Workspace created in the portal, then deleted

Created a workspace by hand before writing the Terraform. Deleted it rather
than importing, so the whole path stays in code. Note that Log Analytics
workspaces soft-delete for 14 days and hold their name during that window.

## Sentinal is moving to the defedner 
so some menu items are now only in defender.