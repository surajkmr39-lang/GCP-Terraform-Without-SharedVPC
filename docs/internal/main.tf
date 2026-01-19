# Root module - main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  
  # Uncomment and configure for remote state
  # First create a GCS bucket in Google Cloud Console, then uncomment below:
  # backend "gcs" {
  #   bucket = "praxis-gear-483220-k4-terraform-state"
  #   prefix = "terraform/state"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Network module
module "network" {
  source = "./modules/network"

  project_id   = var.project_id
  region       = var.region
  environment  = var.environment
  subnet_cidr  = var.subnet_cidr
  
  tags = local.common_tags
}

# Security module
module "security" {
  source = "./modules/security"

  project_id         = var.project_id
  environment        = var.environment
  network_name       = module.network.vpc_name
  subnet_cidr        = var.subnet_cidr
  ssh_source_ranges  = var.ssh_source_ranges
  
  tags = local.common_tags
}

# IAM module
module "iam" {
  source = "./modules/iam"

  project_id         = var.project_id
  environment        = var.environment
  github_repository  = var.github_repository
  
  tags = local.common_tags
}

# Compute module
module "compute" {
  source = "./modules/compute"

  project_id           = var.project_id
  region               = var.region
  zone                 = var.zone
  environment          = var.environment
  machine_type         = var.machine_type
  vm_image             = var.vm_image
  disk_size            = var.disk_size
  ssh_user             = var.ssh_user
  ssh_public_key       = var.ssh_public_key
  startup_script       = var.startup_script
  
  # Dependencies from other modules
  network_name         = module.network.vpc_name
  subnet_name          = module.network.subnet_name
  service_account_email = module.iam.vm_service_account_email
  
  tags = local.common_tags
}

# Local values
locals {
  common_tags = {
    environment = var.environment
    managed_by  = "terraform"
    project     = var.project_id
    team        = var.team
    cost_center = var.cost_center
  }
}