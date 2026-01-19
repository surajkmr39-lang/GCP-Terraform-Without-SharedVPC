# WIF Variables

variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "praxis-gear-483220-k4"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "github_repository" {
  description = "GitHub repository for Workload Identity Federation"
  type        = string
  default     = "surajkmr39-lang/GCP-Terraform"
}