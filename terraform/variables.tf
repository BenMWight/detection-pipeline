variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "australiaeast"
}

variable "resource_group_name" {
  description = "Resource group holding the workspace. Created by this config."
  type        = string
  default     = "rg-detection-pipeline"
}

variable "workspace_name" {
  description = "Log Analytics workspace name. Must be globally unique."
  type        = string
  default     = "law-detection-pipeline"
}

variable "retention_days" {
  description = "Log retention in days. 30 is the free-tier floor; more costs money."
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "Hard ingestion cap in GB/day. -1 is unlimited. Do not use -1."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Applied to every resource so you can find and delete them later."
  type        = map(string)
  default = {
    project    = "detection-pipeline"
    managed_by = "terraform"
    ephemeral  = "true"
  }
}
