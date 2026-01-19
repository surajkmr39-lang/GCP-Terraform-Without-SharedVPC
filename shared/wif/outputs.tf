# WIF Outputs

output "workload_identity_pool_name" {
  description = "The name of the workload identity pool"
  value       = google_iam_workload_identity_pool.github_pool.name
}

output "workload_identity_provider_name" {
  description = "The name of the workload identity provider"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "github_actions_service_account_email" {
  description = "Email of the GitHub Actions service account"
  value       = google_service_account.github_actions_sa.email
}

output "wif_provider_id" {
  description = "Full provider ID for GitHub Actions workflows"
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}