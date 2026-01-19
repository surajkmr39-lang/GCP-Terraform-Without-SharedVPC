# IAM module - Service accounts (Environment-specific only)
# WIF infrastructure moved to shared module

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

# Bind VM service account to shared WIF pool (if WIF pool name is provided)
resource "google_service_account_iam_binding" "vm_wif_binding" {
  count = var.workload_identity_pool_name != "" ? 1 : 0
  
  service_account_id = google_service_account.vm_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  
  members = [
    "principalSet://iam.googleapis.com/${var.workload_identity_pool_name}/attribute.repository/${var.github_repository}"
  ]
}