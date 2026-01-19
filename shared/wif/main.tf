# Workload Identity Federation - Shared Authentication
# Simple, clean WIF configuration for GitHub Actions

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.45.0"
    }
  }
  
  backend "gcs" {
    bucket = "praxis-gear-483220-k4-terraform-state"
    prefix = "shared/wif/terraform-state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Shared GitHub Actions authentication pool"
  project                   = var.project_id
}

# GitHub Provider
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions"
  display_name                       = "GitHub Actions Provider"
  description                        = "GitHub Actions OIDC provider"
  project                            = var.project_id

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.aud"        = "assertion.aud"
  }

  attribute_condition = "assertion.repository == '${var.github_repository}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# GitHub Actions Service Account
resource "google_service_account" "github_actions_sa" {
  account_id   = "github-actions-sa"
  display_name = "GitHub Actions Service Account"
  description  = "Service account for GitHub Actions CI/CD"
  project      = var.project_id
}

# Bind Service Account to WIF
resource "google_service_account_iam_binding" "github_actions_wif_binding" {
  service_account_id = google_service_account.github_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  
  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repository}"
  ]
}

# Grant Terraform Permissions
resource "google_project_iam_member" "github_actions_permissions" {
  for_each = toset([
    "roles/compute.admin",
    "roles/iam.serviceAccountAdmin", 
    "roles/resourcemanager.projectIamAdmin",
    "roles/storage.admin"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}