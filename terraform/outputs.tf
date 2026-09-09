output "resource_group_name" {
  description = "Resource group created. Use this to confirm teardown."
  value       = azurerm_resource_group.this.name
}

# TODO Phase 4: output workspace id and deployed rule names so your evidence
# screenshots can be cross-checked against terraform output.
