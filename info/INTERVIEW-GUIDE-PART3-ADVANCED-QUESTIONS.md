# 🎯 TERRAFORM INTERVIEW PREPARATION - PART 3: ADVANCED QUESTIONS

## 🔥 COMPUTE MODULE DEEP DIVE

### **File: modules/compute/main.tf**

```hcl
resource "google_compute_instance" "vm" {
  name         = "${var.environment}-vm"
  machine_type = var.machine_type
  zone         = var.zone
  
  tags = ["ssh-allowed", "http-allowed", "health-check"]
  
  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = var.disk_size
      type  = "pd-ssd"
    }
  }
  
  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    
    access_config {
      // Ephemeral public IP
    }
  }
  
  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }
  
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}
```

**Interview Question**: "Explain the VM configuration and security features"

**Answer**:
"This creates a hardened VM instance with multiple security layers:

**1. Network Configuration**:
- `network_name` and `subnet_name` - From network module (dependency)
- `access_config {}` - Assigns ephemeral external IP
- `tags` - Links to firewall rules

**2. Service Account**:
- `email = var.service_account_email` - From IAM module
- `scopes = ["cloud-platform"]` - Full GCP API access (controlled by IAM roles)
- **Why cloud-platform scope?** - Permissions controlled by IAM, not scopes

**3. Shielded VM** (Enterprise Security):
- `enable_secure_boot` - Ensures only signed OS boots
- `enable_vtpm` - Virtual Trusted Platform Module for encryption
- `enable_integrity_monitoring` - Detects boot-level tampering

**4. Disk Configuration**:
- `type = "pd-ssd"` - SSD for better performance
- `size = var.disk_size` - Configurable (20GB default)

**Dependencies**:
- Waits for network module (needs network_name)
- Waits for IAM module (needs service_account_email)
- Terraform handles this automatically via implicit dependencies"

---

## 🎤 ADVANCED INTERVIEW QUESTIONS

### **Q1: "How do you handle multiple environments (dev/staging/prod)?"**

**Answer**:
"I use Terraform workspaces and environment-specific tfvars files:

**Approach 1: Workspaces** (What I use)
```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

terraform workspace select dev
terraform apply -var-file="environments/dev/terraform.tfvars"
```

**Approach 2: Separate State Files**
```
environments/
├── dev/
│   ├── terraform.tfvars
│   └── backend.tf (points to dev state)
├── staging/
│   ├── terraform.tfvars
│   └── backend.tf (points to staging state)
```

**My Structure**:
```
environments/
├── dev/terraform.tfvars
│   project_id = "project-dev"
│   machine_type = "e2-medium"
│   
├── staging/terraform.tfvars
│   project_id = "project-staging"
│   machine_type = "e2-standard-2"
│   
└── prod/terraform.tfvars
    project_id = "project-prod"
    machine_type = "n2-standard-4"
```

**Benefits**:
- Same code, different configurations
- Prevents accidental prod changes
- Clear separation
- Easy to promote changes: dev → staging → prod"

---

### **Q2: "What is terraform.tfstate and why is it critical?"**

**Answer**:
"The state file is Terraform's memory of what it created.

**What it contains**:
- Resource IDs (VM ID, VPC ID, etc.)
- Resource attributes (IP addresses, names)
- Metadata (dependencies, timestamps)
- Sensitive data (can include secrets)

**Why it's critical**:
1. **Mapping**: Links Terraform code to real resources
2. **Planning**: Compares desired vs current state
3. **Dependencies**: Tracks resource relationships
4. **Performance**: Caches resource attributes

**Example**:
```
Code says: Create VM named "dev-vm"
State says: VM "dev-vm" exists with ID "12345"
Terraform: No action needed
```

**Security Concerns**:
- Contains sensitive data (IPs, resource IDs)
- Should NEVER be in Git (.gitignore)
- Use remote backend (GCS, S3)
- Enable encryption
- Restrict access

**My Setup**:
```hcl
terraform {
  backend "gcs" {
    bucket = "my-terraform-state"
    prefix = "terraform/state"
  }
}
```

**State Locking**:
- Prevents concurrent modifications
- GCS backend provides automatic locking
- Critical for team collaboration"

---

### **Q3: "Explain implicit vs explicit dependencies"**

**Answer**:
"Terraform has two ways to understand dependencies:

**Implicit Dependencies** (Automatic):
```hcl
resource "google_compute_network" "vpc" {
  name = "my-vpc"
}

resource "google_compute_subnetwork" "subnet" {
  network = google_compute_network.vpc.id  # ← References VPC
}
```
Terraform sees the reference and knows: VPC first, then subnet.

**Explicit Dependencies** (Manual):
```hcl
resource "google_compute_instance" "vm" {
  name = "my-vm"
  
  depends_on = [
    google_compute_firewall.allow_ssh
  ]
}
```
Forces VM to wait for firewall, even without direct reference.

**In My Project**:
- Network module outputs vpc_name
- Compute module uses module.network.vpc_name
- Implicit dependency: Network → Compute

**When to use explicit**:
- No direct reference but logical dependency
- Example: VM needs firewall rule to be ready
- Rare - implicit is preferred"

---

### **Q4: "How do you handle secrets in Terraform?"**

**Answer**:
"I use multiple layers of secret management:

**1. Never in Code**:
```hcl
# BAD
variable "db_password" {
  default = "mypassword123"  # ❌ NEVER
}

# GOOD
variable "db_password" {
  type      = string
  sensitive = true  # Masks in output
}
```

**2. Environment Variables**:
```bash
export TF_VAR_db_password="secret"
terraform apply
```

**3. Secret Manager Integration**:
```hcl
data "google_secret_manager_secret_version" "db_password" {
  secret = "db-password"
}

resource "google_sql_user" "user" {
  password = data.google_secret_manager_secret_version.db_password.secret_data
}
```

**4. .gitignore**:
```
*.tfvars      # Contains actual values
*.tfstate     # Contains resource details
.terraform/   # Provider plugins
```

**5. Sensitive Outputs**:
```hcl
output "db_password" {
  value     = random_password.db.result
  sensitive = true  # Won't show in logs
}
```

**Best Practices**:
- Use terraform.tfvars.example as template
- Store secrets in Secret Manager/Vault
- Mark variables as sensitive
- Use remote state with encryption
- Audit access to state files"

---

### **Q5: "What happens if terraform apply fails halfway?"**

**Answer**:
"Terraform is designed to handle partial failures gracefully:

**Scenario**:
```
Creating VPC... ✓ Success
Creating Subnet... ✓ Success
Creating VM... ✗ Failed (quota exceeded)
```

**What Happens**:
1. **State Updated**: VPC and Subnet are in state file
2. **Partial Infrastructure**: VPC and Subnet exist in GCP
3. **Error Reported**: Terraform shows error message
4. **Next Apply**: Terraform sees VPC/Subnet exist, only retries VM

**State After Failure**:
```hcl
# terraform.tfstate
{
  "resources": [
    {"type": "google_compute_network", "status": "created"},
    {"type": "google_compute_subnetwork", "status": "created"},
    // VM not in state - will retry
  ]
}
```

**Recovery Steps**:
1. Fix the issue (increase quota)
2. Run `terraform apply` again
3. Terraform continues from where it failed
4. Idempotent - safe to re-run

**Rollback**:
```bash
terraform destroy  # Removes everything
# OR
terraform state rm google_compute_network.vpc  # Remove from state
```

**Prevention**:
- Use `terraform plan` first
- Check quotas and permissions
- Test in dev environment
- Use `terraform validate` before apply"

---

### **Q6: "Explain your CI/CD pipeline with Terraform"**

**Answer**:
"I implemented a complete CI/CD pipeline using GitHub Actions with Workload Identity Federation:

**Pipeline Stages**:

**1. Validation** (On Pull Request):
```yaml
- terraform fmt -check    # Code formatting
- terraform validate      # Syntax check
- terraform plan          # Show changes
- checkov scan           # Security scanning
```

**2. Security Scanning**:
- Checkov scans for misconfigurations
- Checks for public IPs, open firewalls
- Validates encryption settings
- Fails if critical issues found

**3. Plan Review**:
- Posts plan as PR comment
- Team reviews changes
- Approval required for merge

**4. Deployment** (On Merge to Main):
```yaml
- Authenticate via WIF (no keys!)
- terraform apply -auto-approve
- Post outputs as comment
- Update documentation
```

**Key Features**:
- **Keyless Auth**: WIF eliminates service account keys
- **Automated**: No manual terraform commands
- **Safe**: Plan review before apply
- **Auditable**: All changes in Git history
- **Fast**: Parallel execution where possible

**Workflow File** (`.github/workflows/cicd-pipeline.yml`):
- Triggers on push to main
- Uses google-github-actions/auth with WIF
- Runs terraform in GitHub-hosted runner
- Stores state in GCS bucket

**Benefits**:
- Infrastructure changes follow code review process
- Automated testing prevents errors
- Consistent deployments
- Team collaboration
- Compliance and audit trail"

---

