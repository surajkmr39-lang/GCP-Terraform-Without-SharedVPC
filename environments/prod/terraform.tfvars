# Production Environment Configuration
# Enterprise Naming Convention: {company}-{product}-{environment}-{component}
# Remote Backend: State stored in GCS bucket

# ===================================================================
# PROJECT CONFIGURATION
# ===================================================================
project_id = "praxis-gear-483220-k4"
region     = "us-central1"
zone       = "us-central1-b"  # Different zone for availability

# ===================================================================
# ENVIRONMENT CONFIGURATION (Enterprise Naming)
# ===================================================================
environment = "production"  # Full name for enterprise clarity
subnet_cidr = "10.30.0.0/16"  # Enterprise CIDR block (production range)

# ===================================================================
# COMPUTE CONFIGURATION (Production-sized)
# ===================================================================
machine_type = "e2-standard-4"  # 4 vCPUs, 16GB RAM (production-grade)
vm_image     = "ubuntu-os-cloud/ubuntu-2204-lts"
disk_size    = 100  # 100GB (production storage requirements)

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
# SECURITY CONFIGURATION (Production - Highly Restricted)
# ===================================================================
ssh_source_ranges = ["203.0.113.0/24", "198.51.100.0/24"]  # Office/VPN networks only

# ===================================================================
# VM STARTUP SCRIPT (Production)
# ===================================================================
startup_script = "../../scripts/production-startup.sh"