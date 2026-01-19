# Staging Environment Configuration
# Enterprise Naming Convention: {company}-{product}-{environment}-{component}
# Remote Backend: State stored in GCS bucket

# ===================================================================
# PROJECT CONFIGURATION
# ===================================================================
project_id = "praxis-gear-483220-k4"
region     = "us-central1"
zone       = "us-central1-c"  # Different zone for availability

# ===================================================================
# ENVIRONMENT CONFIGURATION (Enterprise Naming)
# ===================================================================
environment = "staging"  # Standard enterprise environment name
subnet_cidr = "10.20.0.0/16"  # Enterprise CIDR block (staging range)

# ===================================================================
# COMPUTE CONFIGURATION (Staging-sized)
# ===================================================================
machine_type = "e2-standard-2"  # 2 vCPUs, 8GB RAM (production-like)
vm_image     = "ubuntu-os-cloud/ubuntu-2204-lts"
disk_size    = 50  # 50GB (production-like sizing)

# ===================================================================
# SSH CONFIGURATION
# ===================================================================
ssh_user       = "ubuntu"
ssh_public_key = ""

# ===================================================================
# WORKLOAD IDENTITY FEDERATION
# ===================================================================
github_repository = "surajkmr39-lang/GCP-Terraform"

# ===================================================================
# ENTERPRISE METADATA (Real-world tags)
# ===================================================================
team        = "platform-engineering"
cost_center = "engineering-ops"

# ===================================================================
# SECURITY CONFIGURATION (Staging - Restricted Access)
# ===================================================================
ssh_source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]  # Private networks only

# ===================================================================
# VM STARTUP SCRIPT (Staging)
# ===================================================================
startup_script = "../../scripts/staging-startup.sh"