# 🧠 Interview Guide Part 3: Advanced Questions

## 🚀 **Performance Optimization**

### **Q: "How would you optimize Terraform performance for large infrastructures?"**

**A:** "I'd implement several optimization strategies:

**1. Parallelism Control:**
```bash
terraform apply -parallelism=20  # Increase concurrent operations
```

**2. Targeted Operations:**
```bash
terraform apply -target=module.compute  # Deploy specific modules
terraform plan -target=google_compute_instance.vm
```

**3. State Management:**
- Use remote state with proper locking
- Implement state file splitting for large infrastructures
- Regular state file cleanup and optimization

**4. Resource Organization:**
- Modular architecture to limit blast radius
- Separate state files for independent components
- Use data sources instead of resource references where possible

**5. Provider Optimization:**
```hcl
provider "google" {
  request_timeout = "60s"
  request_reason  = "terraform-deployment"
}
```

In my project, I use modules to parallelize deployment and separate state files per environment for optimal performance."

### **Q: "How do you handle Terraform state file corruption or loss?"**

**A:** "I have a comprehensive disaster recovery strategy:

**1. Prevention:**
- Remote state with automatic backups (GCS versioning)
- State locking to prevent concurrent modifications
- Regular state file backups

**2. Detection:**
```bash
terraform plan  # Will show drift if state is corrupted
terraform refresh  # Update state from real resources
```

**3. Recovery Options:**

**Option 1: Restore from Backup:**
```bash
gsutil ls -a gs://bucket/path/  # List all versions
gsutil cp gs://bucket/path/terraform.tfstate#version ./terraform.tfstate
```

**Option 2: Import Existing Resources:**
```bash
terraform import google_compute_instance.vm projects/PROJECT/zones/ZONE/instances/NAME
terraform import google_compute_network.vpc projects/PROJECT/global/networks/NAME
```

**Option 3: Recreate State:**
```bash
terraform init -reconfigure
terraform import [resource_type].[resource_name] [resource_id]
```

My GCS backend provides automatic versioning, so I can always restore to a previous working state."

## 🔧 **Complex Scenarios**

### **Q: "How would you implement blue-green deployments with Terraform?"**

**A:** "I'd implement blue-green deployments using multiple approaches:

**1. Instance Group Approach:**
```hcl
resource "google_compute_instance_group_manager" "blue" {
  count = var.active_deployment == "blue" ? 1 : 0
  name  = "${var.environment}-blue-igm"
  # ... configuration
}

resource "google_compute_instance_group_manager" "green" {
  count = var.active_deployment == "green" ? 1 : 0
  name  = "${var.environment}-green-igm"
  # ... configuration
}

resource "google_compute_url_map" "main" {
  default_service = var.active_deployment == "blue" ? 
    google_compute_backend_service.blue[0].id : 
    google_compute_backend_service.green[0].id
}
```

**2. Workspace-based Approach:**
```bash
# Deploy to green environment
terraform workspace select green
terraform apply

# Switch traffic
terraform workspace select production
terraform apply -var="active_deployment=green"

# Cleanup blue environment
terraform workspace select blue
terraform destroy
```

**3. Module-based Approach:**
```hcl
module "blue_environment" {
  source = "./modules/environment"
  count  = var.blue_active ? 1 : 0
  # ... configuration
}

module "green_environment" {
  source = "./modules/environment"
  count  = var.green_active ? 1 : 0
  # ... configuration
}
```

The key is maintaining two identical environments and switching traffic atomically."

### **Q: "How do you handle secrets and sensitive data in Terraform?"**

**A:** "I use multiple layers of secret management:

**1. Google Secret Manager Integration:**
```hcl
data "google_secret_manager_secret_version" "db_password" {
  secret = "database-password"
}

resource "google_compute_instance" "vm" {
  metadata = {
    db-password = data.google_secret_manager_secret_version.db_password.secret_data
  }
}
```

**2. Terraform Sensitive Variables:**
```hcl
variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

output "connection_string" {
  value     = "postgresql://user:${var.database_password}@${google_sql_database_instance.main.ip_address}"
  sensitive = true
}
```

**3. External Data Sources:**
```hcl
data "external" "vault_secret" {
  program = ["vault", "kv", "get", "-format=json", "secret/myapp"]
}
```

**4. Environment Variables:**
```bash
export TF_VAR_database_password=$(vault kv get -field=password secret/db)
terraform apply
```

**5. Workload Identity for Service Authentication:**
- No stored service account keys
- OIDC token-based authentication
- Attribute-based access control

In my project, I use Workload Identity Federation to eliminate stored credentials entirely."

## 🔍 **Troubleshooting & Debugging**

### **Q: "How do you debug Terraform issues?"**

**A:** "I use a systematic debugging approach:

**1. Enable Debug Logging:**
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log
terraform apply
```

**2. Validate Configuration:**
```bash
terraform validate
terraform fmt -check
terraform plan -detailed-exitcode
```

**3. State Inspection:**
```bash
terraform state list
terraform state show resource.name
terraform refresh
```

**4. Provider-specific Debugging:**
```bash
export GOOGLE_CREDENTIALS_DEBUG=true
gcloud auth application-default print-access-token
```

**5. Resource-specific Investigation:**
```bash
gcloud compute instances describe INSTANCE_NAME --zone=ZONE
gcloud compute networks describe NETWORK_NAME
```

**6. Common Issues and Solutions:**

**State Lock Issues:**
```bash
terraform force-unlock LOCK_ID
```

**Provider Authentication:**
```bash
gcloud auth application-default login
gcloud config set project PROJECT_ID
```

**Resource Conflicts:**
```bash
terraform import resource.name existing_resource_id
```

**7. Testing Approach:**
```bash
terraform plan -out=tfplan
terraform show -json tfplan | jq '.planned_values'
```

I also use `terraform console` to test expressions and validate interpolations."

### **Q: "How do you handle Terraform version upgrades?"**

**A:** "I follow a structured upgrade process:

**1. Version Constraints:**
```hcl
terraform {
  required_version = ">= 1.0, < 2.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
```

**2. Upgrade Process:**
```bash
# 1. Backup current state
terraform state pull > backup.tfstate

# 2. Test in development first
cd environments/dev
terraform init -upgrade
terraform plan

# 3. Validate no changes
terraform plan -detailed-exitcode

# 4. Apply to staging
cd ../staging
terraform init -upgrade
terraform plan
terraform apply

# 5. Finally upgrade production
cd ../prod
terraform init -upgrade
terraform plan
terraform apply
```

**3. Provider Upgrade Testing:**
```bash
terraform providers lock -platform=linux_amd64 -platform=darwin_amd64
terraform init -upgrade
terraform plan -refresh-only
```

**4. Rollback Strategy:**
```bash
# If issues occur, rollback
terraform init -reconfigure
# Restore from backup if needed
terraform state push backup.tfstate
```

I always test upgrades in lower environments first and maintain version constraints to prevent unexpected changes."

## 🏗️ **Architecture & Design**

### **Q: "How would you design Terraform infrastructure for a microservices architecture?"**

**A:** "I'd design a scalable, modular infrastructure:

**1. Hierarchical Module Structure:**
```
infrastructure/
├── shared/                    # Shared resources
│   ├── network/              # VPC, subnets
│   ├── security/             # IAM, firewall
│   └── monitoring/           # Logging, metrics
├── services/                 # Service-specific
│   ├── user-service/
│   ├── order-service/
│   └── payment-service/
└── environments/             # Environment configs
    ├── dev/
    ├── staging/
    └── prod/
```

**2. Service Module Template:**
```hcl
module "user_service" {
  source = "../modules/microservice"
  
  service_name = "user-service"
  environment  = var.environment
  
  # Compute
  min_replicas = var.environment == "prod" ? 3 : 1
  max_replicas = var.environment == "prod" ? 10 : 3
  machine_type = var.environment == "prod" ? "e2-standard-2" : "e2-micro"
  
  # Networking
  vpc_network = module.shared.vpc_network
  subnet      = module.shared.private_subnet
  
  # Database
  database_instance = module.shared.database_instance
  database_name     = "users"
  
  # Monitoring
  enable_monitoring = true
  log_level        = var.environment == "prod" ? "INFO" : "DEBUG"
}
```

**3. Shared Infrastructure:**
```hcl
module "shared_infrastructure" {
  source = "./modules/shared"
  
  # Network
  vpc_cidr = "10.0.0.0/16"
  
  # Database
  database_tier = var.environment == "prod" ? "db-n1-standard-2" : "db-f1-micro"
  
  # Load Balancing
  enable_cdn = var.environment == "prod"
  
  # Monitoring
  enable_alerting = var.environment == "prod"
}
```

**4. Service Discovery:**
```hcl
resource "google_dns_managed_zone" "services" {
  name     = "${var.environment}-services"
  dns_name = "${var.environment}.internal."
}

resource "google_dns_record_set" "service" {
  for_each = var.services
  
  name = "${each.key}.${google_dns_managed_zone.services.dns_name}"
  type = "A"
  ttl  = 300
  
  rrdatas = [each.value.ip_address]
}
```

This approach provides service isolation, shared resource efficiency, and environment consistency."

### **Q: "How do you implement disaster recovery with Terraform?"**

**A:** "I implement comprehensive disaster recovery:

**1. Multi-Region Architecture:**
```hcl
module "primary_region" {
  source = "./modules/infrastructure"
  
  region      = "us-central1"
  environment = var.environment
  is_primary  = true
}

module "dr_region" {
  source = "./modules/infrastructure"
  
  region      = "us-west1"
  environment = var.environment
  is_primary  = false
  
  # Reduced capacity for DR
  min_instances = 1
  max_instances = 3
}
```

**2. Data Replication:**
```hcl
resource "google_sql_database_instance" "primary" {
  name   = "${var.environment}-db-primary"
  region = "us-central1"
  
  replica_configuration {
    failover_target = true
  }
}

resource "google_sql_database_instance" "replica" {
  name                 = "${var.environment}-db-replica"
  region               = "us-west1"
  master_instance_name = google_sql_database_instance.primary.name
}
```

**3. State Management DR:**
```hcl
terraform {
  backend "gcs" {
    bucket = "primary-terraform-state"
  }
}

# Backup state to secondary region
resource "google_storage_bucket" "state_backup" {
  name     = "dr-terraform-state-backup"
  location = "us-west1"
  
  versioning {
    enabled = true
  }
}
```

**4. Automated Failover:**
```hcl
resource "google_compute_global_forwarding_rule" "main" {
  name       = "${var.environment}-lb"
  target     = google_compute_target_http_proxy.main.id
  port_range = "80"
}

resource "google_compute_backend_service" "main" {
  name = "${var.environment}-backend"
  
  dynamic "backend" {
    for_each = var.enable_dr ? [var.primary_backend, var.dr_backend] : [var.primary_backend]
    content {
      group = backend.value
    }
  }
  
  health_checks = [google_compute_health_check.main.id]
}
```

**5. Recovery Procedures:**
```bash
# Automated DR activation
terraform apply -var="enable_dr=true" -var="primary_region_down=true"

# Manual failover
terraform workspace select dr
terraform apply -var="activate_dr=true"
```

The key is automation, regular testing, and clear recovery procedures."

## 🎯 **Advanced Interview Questions & Answers**

### **Q: "How do you implement infrastructure testing with Terraform?"**

**A:** "I implement multiple testing layers:

**1. Unit Testing with Terratest:**
```go
func TestTerraformNetwork(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/network",
        Vars: map[string]interface{}{
            "environment": "test",
            "subnet_cidr": "10.100.0.0/16",
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    vpcName := terraform.Output(t, terraformOptions, "vpc_name")
    assert.Equal(t, "test-vpc", vpcName)
}
```

**2. Integration Testing:**
```bash
# Test complete environment deployment
cd environments/test
terraform init
terraform apply -auto-approve
terraform output -json > outputs.json

# Validate infrastructure
gcloud compute instances list --filter="name:test-vm" --format="value(status)"
```

**3. Policy Testing with OPA:**
```rego
package terraform.security

deny[msg] {
    resource := input.planned_values.root_module.resources[_]
    resource.type == "google_compute_firewall"
    "0.0.0.0/0" in resource.values.source_ranges
    msg := "Firewall rule allows access from anywhere"
}
```

**4. Compliance Testing:**
```bash
# Security scanning
checkov -f main.tf --framework terraform
tfsec .
terraform-compliance -f compliance/ -p tfplan
```

This ensures infrastructure quality and security compliance."

### **Q: "How do you handle Terraform in a CI/CD pipeline with multiple teams?"**

**A:** "I implement a collaborative CI/CD strategy:

**1. Branch-based Workflows:**
```yaml
# .github/workflows/terraform.yml
on:
  pull_request:
    paths: ['environments/**', 'modules/**']
  push:
    branches: [main]

jobs:
  plan:
    if: github.event_name == 'pull_request'
    strategy:
      matrix:
        environment: [dev, staging, prod]
    steps:
      - name: Terraform Plan
        run: |
          cd environments/${{ matrix.environment }}
          terraform plan -out=tfplan
          terraform show -no-color tfplan > plan.txt
      
      - name: Comment PR
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const plan = fs.readFileSync('plan.txt', 'utf8');
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Terraform Plan - ${{ matrix.environment }}\n\`\`\`\n${plan}\n\`\`\``
            });
```

**2. Team-based Access Control:**
```hcl
# Different service accounts per team
resource "google_service_account" "platform_team" {
  account_id = "platform-team-terraform"
}

resource "google_service_account" "app_team" {
  account_id = "app-team-terraform"
}

# Restricted permissions
resource "google_project_iam_member" "platform_team" {
  for_each = toset([
    "roles/compute.admin",
    "roles/iam.serviceAccountAdmin"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.platform_team.email}"
}
```

**3. State Management Strategy:**
```bash
# Team-specific state prefixes
environments/
├── platform/
│   ├── network/     # Platform team owns
│   └── security/    # Platform team owns
└── applications/
    ├── frontend/    # App team owns
    └── backend/     # App team owns
```

**4. Approval Workflows:**
```yaml
environment:
  name: production
  protection_rules:
    - type: required_reviewers
      required_reviewers:
        - platform-team
    - type: wait_timer
      wait_timer: 5
```

This ensures safe collaboration while maintaining team autonomy."

**Next:** Continue to [Part 4: Scenario Questions](INTERVIEW-GUIDE-PART4-SCENARIO-QUESTIONS.md) for real-world problem-solving scenarios.