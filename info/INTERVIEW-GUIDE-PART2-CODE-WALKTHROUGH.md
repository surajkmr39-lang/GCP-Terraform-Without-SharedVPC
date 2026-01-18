# 🔍 Interview Guide Part 2: Code Walkthrough

## 🏗️ **Project Structure Deep Dive**

### **Root Directory Overview:**
```
GCP-Terraform/
├── main.tf                    # Root configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── terraform.tfvars           # Current environment values
├── modules/                   # Reusable modules
├── environments/              # Environment-specific configs
└── .github/workflows/         # CI/CD pipelines
```

## 📄 **Root Configuration Files**

### **main.tf - Root Configuration:**
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Network Module
module "network" {
  source = "./modules/network"
  
  project_id   = var.project_id
  region       = var.region
  environment  = var.environment
  subnet_cidr  = var.subnet_cidr
}

# Security Module
module "security" {
  source = "./modules/security"
  
  project_id  = var.project_id
  environment = var.environment
  vpc_name    = module.network.vpc_name
}

# IAM Module
module "iam" {
  source = "./modules/iam"
  
  project_id        = var.project_id
  environment       = var.environment
  github_repository = var.github_repository
}

# Compute Module
module "compute" {
  source = "./modules/compute"
  
  project_id     = var.project_id
  region         = var.region
  zone           = var.zone
  environment    = var.environment
  machine_type   = var.machine_type
  vm_image       = var.vm_image
  disk_size      = var.disk_size
  ssh_user       = var.ssh_user
  ssh_public_key = var.ssh_public_key
  startup_script = var.startup_script
  
  vpc_name           = module.network.vpc_name
  subnet_name        = module.network.subnet_name
  service_account_email = module.iam.vm_service_account_email
  
  depends_on = [
    module.network,
    module.security,
    module.iam
  ]
}
```

**Key Points:**
- **Provider configuration**: Specifies Google Cloud provider
- **Module composition**: Each module handles specific infrastructure area
- **Dependency management**: `depends_on` ensures proper creation order
- **Variable passing**: Modules receive configuration through variables

### **variables.tf - Variable Definitions:**
```hcl
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  
  validation {
    condition = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.10.0.0/16"
}

variable "machine_type" {
  description = "Machine type for the VM instance"
  type        = string
  default     = "e2-medium"
}

variable "github_repository" {
  description = "GitHub repository for Workload Identity Federation"
  type        = string
  default     = "surajkmr39-lang/GCP-Terraform"
}
```

**Key Points:**
- **Type safety**: All variables have explicit types
- **Validation rules**: Environment variable has validation
- **Default values**: Sensible defaults for optional variables
- **Documentation**: Clear descriptions for all variables

## 📦 **Module Architecture**

### **Network Module (modules/network/):**

**main.tf:**
```hcl
# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "${var.environment}-vpc"
  auto_create_subnetworks = false
  routing_mode           = "REGIONAL"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.environment}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  
  private_ip_google_access = true
}

# Cloud Router
resource "google_compute_router" "router" {
  name    = "${var.environment}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

# Cloud NAT
resource "google_compute_router_nat" "nat" {
  name   = "${var.environment}-nat"
  router = google_compute_router.router.name
  region = var.region
  
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
```

**Key Design Decisions:**
- **Custom VPC**: Disabled auto-create for full control
- **Private Google Access**: Enables access to Google APIs without external IP
- **Cloud NAT**: Provides outbound internet access for private instances
- **Regional routing**: Optimized for single-region deployment

### **Security Module (modules/security/):**

**main.tf:**
```hcl
# SSH Access
resource "google_compute_firewall" "ssh" {
  name    = "${var.environment}-allow-ssh"
  network = var.vpc_name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]  # Restrict in production
  target_tags   = ["ssh-allowed"]
}

# HTTP/HTTPS Access
resource "google_compute_firewall" "http_https" {
  name    = "${var.environment}-allow-http-https"
  network = var.vpc_name
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-allowed"]
}

# Internal Communication
resource "google_compute_firewall" "internal" {
  name    = "${var.environment}-allow-internal"
  network = var.vpc_name
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = ["10.0.0.0/8"]
  target_tags   = ["internal"]
}

# Health Check Access
resource "google_compute_firewall" "health_check" {
  name    = "${var.environment}-allow-health-check"
  network = var.vpc_name
  
  allow {
    protocol = "tcp"
  }
  
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
  target_tags = ["health-check"]
}
```

**Security Principles:**
- **Least privilege**: Only necessary ports opened
- **Tag-based targeting**: Flexible firewall application
- **Health check support**: Google Cloud load balancer ranges
- **Internal communication**: Private network access

### **IAM Module (modules/iam/):**

**main.tf:**
```hcl
# VM Service Account
resource "google_service_account" "vm_sa" {
  account_id   = "${var.environment}-vm-sa"
  display_name = "${title(var.environment)} VM Service Account"
  description  = "Service account for ${var.environment} VM instances"
}

# Service Account Roles
resource "google_project_iam_member" "vm_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.dashboardEditor",
    "roles/compute.instanceAdmin.v1"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

# Workload Identity Pool
resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Identity pool for GitHub Actions"
}

# GitHub Provider
resource "google_iam_workload_identity_pool_provider" "provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub Actions Provider"
  
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Service Account Impersonation
resource "google_service_account_iam_member" "wif_sa" {
  service_account_id = google_service_account.vm_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/attribute.repository/${var.github_repository}"
}
```

**IAM Best Practices:**
- **Dedicated service accounts**: Separate SA for each purpose
- **Minimal permissions**: Only required roles assigned
- **Workload Identity Federation**: Keyless authentication
- **Attribute-based access**: Repository-specific access

### **Compute Module (modules/compute/):**

**main.tf:**
```hcl
# VM Instance
resource "google_compute_instance" "vm" {
  name         = "${var.environment}-vm"
  machine_type = var.machine_type
  zone         = var.zone
  
  tags = ["ssh-allowed", "http-allowed", "internal", "health-check"]
  
  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = var.disk_size
      type  = "pd-ssd"
    }
  }
  
  network_interface {
    network    = var.vpc_name
    subnetwork = var.subnet_name
    
    access_config {
      # Ephemeral external IP
    }
  }
  
  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }
  
  metadata = {
    ssh-keys               = "${var.ssh_user}:${var.ssh_public_key}"
    block-project-ssh-keys = "true"
    startup-script         = var.startup_script
  }
  
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  
  lifecycle {
    create_before_destroy = true
  }
}
```

**Compute Best Practices:**
- **Security hardening**: Shielded VM with secure boot
- **Network tags**: Applied for firewall targeting
- **SSD disks**: Better performance than standard disks
- **Lifecycle management**: Safe replacement strategy
- **Metadata security**: Block project-wide SSH keys

## 🌍 **Environment-Specific Configurations**

### **Development Environment (environments/dev/):**

**main.tf:**
```hcl
terraform {
  backend "gcs" {
    bucket = "praxis-gear-483220-k4-terraform-state"
    prefix = "environments/development/terraform-state"
  }
}

module "infrastructure" {
  source = "../../"
  
  project_id   = var.project_id
  region       = var.region
  zone         = var.zone
  environment  = var.environment
  subnet_cidr  = var.subnet_cidr
  machine_type = var.machine_type
  vm_image     = var.vm_image
  disk_size    = var.disk_size
  
  ssh_user       = var.ssh_user
  ssh_public_key = var.ssh_public_key
  startup_script = var.startup_script
  
  github_repository = var.github_repository
  team             = var.team
  cost_center      = var.cost_center
}
```

**terraform.tfvars:**
```hcl
# Development Environment Configuration
project_id = "praxis-gear-483220-k4"
region     = "us-central1"
zone       = "us-central1-a"

environment = "development"
subnet_cidr = "10.10.0.0/16"

machine_type = "e2-medium"
vm_image     = "ubuntu-os-cloud/ubuntu-2204-lts"
disk_size    = 30

github_repository = "surajkmr39-lang/GCP-Terraform"
team             = "platform-engineering"
cost_center      = "engineering-ops"
```

## 🔄 **Resource Dependencies**

### **Dependency Graph:**
```
Provider (google) 
    ↓
Network Module
    ↓
Security Module (depends on VPC)
    ↓
IAM Module
    ↓
Compute Module (depends on all above)
```

### **Implicit Dependencies:**
- VM instance → Subnet (network interface)
- Firewall rules → VPC network
- Service account → IAM roles
- Cloud NAT → Cloud Router

### **Explicit Dependencies:**
```hcl
depends_on = [
  module.network,
  module.security,
  module.iam
]
```

## 🎯 **Interview Questions & Answers**

### **Q: "Walk me through your Terraform project structure."**
**A:** "My project uses a modular architecture with four main modules: network for VPC and subnets, security for firewall rules, IAM for service accounts and Workload Identity, and compute for VM instances. Each environment has its own directory with specific configurations and remote state. The root configuration orchestrates all modules and handles dependencies."

### **Q: "How do you handle dependencies between resources?"**
**A:** "I use both implicit and explicit dependencies. Implicit dependencies are created when one resource references another, like the VM referencing the subnet. For complex dependencies, I use explicit `depends_on` to ensure proper creation order. My compute module depends on network, security, and IAM modules being created first."

### **Q: "Explain your variable strategy."**
**A:** "I use a hierarchical variable approach. Root variables define common parameters, modules have their own variables for specific configuration, and each environment overrides values in terraform.tfvars. I include validation rules for critical variables like environment names and provide sensible defaults where appropriate."

### **Q: "How do you ensure security in your Terraform code?"**
**A:** "I implement multiple security layers: Workload Identity Federation for keyless authentication, minimal IAM permissions following least privilege, Shielded VMs with secure boot, firewall rules with specific port access, and private subnets with Cloud NAT for outbound access. All security configurations are in a dedicated module."

### **Q: "How do you manage different environments?"**
**A:** "I use a directory-based approach with separate folders for dev, staging, and prod. Each environment has its own state file, configuration, and variables. This provides complete isolation and allows environment-specific resource sizing - development uses e2-medium instances while production uses e2-standard-4."

## 📚 **Code Quality Practices**

### **Naming Conventions:**
- Resources: `${environment}-${resource-type}`
- Variables: Descriptive names with validation
- Modules: Functional grouping (network, security, iam, compute)

### **Documentation:**
- Variable descriptions for all inputs
- Output descriptions for all exports
- README files in each module
- Inline comments for complex logic

### **Validation:**
- Variable validation rules
- Type constraints on all variables
- Required provider versions
- Terraform version constraints

**Next:** Continue to [Part 3: Advanced Questions](INTERVIEW-GUIDE-PART3-ADVANCED-QUESTIONS.md) for complex scenarios and troubleshooting.