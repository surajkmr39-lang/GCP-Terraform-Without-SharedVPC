output "network" {
  description = "Network module outputs"
  value = {
    vpc_name    = module.network.vpc_name
    vpc_id      = module.network.vpc_id
    subnet_name = module.network.subnet_name
    subnet_cidr = module.network.subnet_cidr
  }
}

output "compute" {
  description = "Compute module outputs"
  value = {
    vm_name        = module.compute.vm_name
    vm_external_ip = module.compute.vm_external_ip
    vm_internal_ip = module.compute.vm_internal_ip
    ssh_command    = module.compute.ssh_command
  }
}

output "iam" {
  description = "IAM module outputs"
  value = {
    service_account_email              = module.iam.vm_service_account_email
    workload_identity_pool_name        = module.iam.workload_identity_pool_name
    workload_identity_provider_name    = module.iam.workload_identity_provider_name
  }
}