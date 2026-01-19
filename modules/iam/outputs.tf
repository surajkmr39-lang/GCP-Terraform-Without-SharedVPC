output "vm_service_account_email" {
  description = "Email of the VM service account"
  value       = google_service_account.vm_service_account.email
}

output "vm_service_account_name" {
  description = "Name of the VM service account"
  value       = google_service_account.vm_service_account.name
}