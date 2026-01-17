# IAM module - Service accounts and workload identity
resource "google_service_account" "vm_service_account" {
  account_id   = "${var.environment}-vm-sa"
  display_name = "Service Account for ${var.environment} VM"
  description  = "Service account used by VM instances in ${var.environment} environment"
  project      = var.project_id
}

# IAM bindings for the service account
resource "google_project_iam_member" "vm_sa_compute_viewer" {
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

resource "google_project_iam_member" "vm_sa_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

resource "google_project_iam_member" "vm_sa_logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

resource "google_project_iam_member" "vm_sa_monitoring_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

# Workload Identity Pool
resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = "github-pool"
  display_name              = "github-pool"
  description               = "GitHub Actions authentication pool"
  project                   = var.project_id
}

# Workload Identity Pool Provider for GitHub Actions
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  count = var.github_repository != "" ? 1 : 0
  
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "github"
  description                        = "GitHub Actions provider for workload identity"
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

# IAM binding for workload identity
resource "google_service_account_iam_binding" "workload_identity_binding" {
  count = var.github_repository != "" ? 1 : 0
  
  service_account_id = google_service_account.vm_service_account.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.github_repository}"
  ]
}