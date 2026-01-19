# Production Environment Outputs
output "network" {
  description = "Network configuration details"
  value = {
    vpc_name    = module.network.vpc_name
    vpc_id      = module.network.vpc_id
    subnet_name = module.network.subnet_name
    subnet_cidr = module.network.subnet_cidr
  }
}

output "compute" {
  description = "Compute instance details"
  value = {
    vm_name        = module.compute.vm_name
    vm_internal_ip = module.compute.vm_internal_ip
    vm_external_ip = module.compute.vm_external_ip
    ssh_command    = module.compute.ssh_command
  }
}

output "iam" {
  description = "IAM configuration details"
  value = {
    service_account_email = module.iam.vm_service_account_email
  }
}

output "shared_wif" {
  description = "Shared WIF configuration details"
  value = {
    workload_identity_pool_name     = data.terraform_remote_state.shared_wif.outputs.workload_identity_pool_name
    workload_identity_provider_name = data.terraform_remote_state.shared_wif.outputs.workload_identity_provider_name
    github_actions_service_account  = data.terraform_remote_state.shared_wif.outputs.github_actions_service_account_email
  }
}

output "backend_info" {
  description = "Backend configuration information"
  value = {
    backend_type = "gcs"
    bucket       = "praxis-gear-483220-k4-terraform-state"
    prefix       = "environments/production/terraform-state"
    state_location = "Remote (Google Cloud Storage)"
  }
}