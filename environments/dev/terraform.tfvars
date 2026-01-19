# Development Environment Configuration
# Enterprise Naming Convention: {company}-{product}-{environment}-{component}
# Remote Backend: State stored in GCS bucket

# ===================================================================
# PROJECT CONFIGURATION
# ===================================================================
project_id = "praxis-gear-483220-k4"
region     = "us-central1"
zone       = "us-central1-a"

# ===================================================================
# ENVIRONMENT CONFIGURATION (Enterprise Naming)
# ===================================================================
environment = "development"  # Full name for enterprise clarity
subnet_cidr = "10.10.0.0/16"  # Enterprise CIDR block

# ===================================================================
# COMPUTE CONFIGURATION (Development-sized)
# ===================================================================
machine_type = "e2-medium"  # 2 vCPUs, 4GB RAM (cost-optimized for dev)
vm_image     = "ubuntu-os-cloud/ubuntu-2204-lts"
disk_size    = 30  # 30GB (adequate for development)

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
# SECURITY CONFIGURATION (Development - Restricted Access)
# ===================================================================
ssh_source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]  # Private networks only

# ===================================================================
# VM STARTUP SCRIPT (Development)
# ===================================================================
startup_script = "../../scripts/development-startup.sh"