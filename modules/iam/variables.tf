variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository for workload identity (format: owner/repo)"
  type        = string
  default     = ""
}

variable "workload_identity_pool_name" {
  description = "Name of the shared workload identity pool"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}