# Decisions and issues

Running log of choices made and problems hit. Written as they happened, not
reconstructed afterwards.

## Provider registration: skipped auto, registered manually

The azurerm provider tries to register roughly 60 resource provider namespaces
on every plan. On a subscription where the signed-in identity had no role
assignment this failed with 403 across all of them, which buried