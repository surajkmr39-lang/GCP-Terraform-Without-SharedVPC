# 🎭 Phase 3: Service Account Impersonation - Enterprise Security

**Duration**: 1 hour  
**Difficulty**: ⭐⭐⭐ Advanced  
**Security Level**: ⭐⭐⭐⭐ Enterprise Grade

## 🎯 Learning Objectives

By the end of this phase, you'll understand:
- How service account impersonation works
- Setting up cross-environment access patterns
- Enterprise security benefits
- Implementing audit trails and access controls
- Real-world impersonation scenarios

## 🏗️ What We'll Build

We'll create a realistic enterprise scenario:
- **Dev Environment**: Your current setup
- **Staging Environment**: New environment with impersonation
- **Cross-Environment Access**: Secure access patterns
- **Audit Trail**: Complete logging and monitoring

## 🎭 Understanding Impersonation

### **The Concept**
Instead of using service account keys, you use your own credentials to "impersonate" (temporarily become) a service account.

```
Your Identity → Request Impersonation → GCP Validates → Temporary Token → Access Resources
```

### **Security Benefits**
- ✅ No stored keys
- ✅ Full audit trail (who impersonated when)
- ✅ Time-limited access (1 hour tokens)
- ✅ Centralized permission management
- ✅ Easy to revoke access

## 🛠️ Step 1: Create Staging Environment Setup

First, let's create a staging environment to demonstrate cross-environment patterns:

```bash
# 1. Create staging-specific service accounts
gcloud iam service-accounts create staging-terraform-sa \
    --display-name="Staging Terraform Service Account" \
    --description="Service account for staging Terraform operations" \
    --project=praxis-gear-483220-k4

gcloud iam service-accounts create staging-vm-sa \
    --display-name="Staging VM Service Account" \
    --description="Service account for staging VM instances" \
    --project=praxis-gear-483220-k4

# 2. Grant staging-terraform-sa the necessary permissions
gcloud projects add-iam-policy-binding praxis-gear-483220-k4 \
    --member="serviceAccount:staging-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding praxis-gear-483220-k4 \
    --member="serviceAccount:staging-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

# 3. Grant your user account impersonation permissions
gcloud iam service-accounts add-iam-policy-binding \
    staging-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com \
    --member="user:rksuraj@learningmyway.space" \
    --role="roles/iam.serviceAccountTokenCreator"

# 4. Verify the setup
gcloud iam service-accounts get-iam-policy \
    staging-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com
```

## 🔧 Step 2: Configure Terraform for Impersonation

Create a staging-specific Terraform configuration:

```bash
# Create staging directory structure
mkdir -p labs/phase-3-impersonation/staging-config
```

Create the staging provider configuration:

```hcl
# Save as: labs/phase-3-impersonation/staging-config/main.tf

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Provider with impersonation
provider "google" {
  project = var.project_id
  region  = var.region
  
  # This is the key difference - impersonation!
  impersonate_service_account = "staging-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com"
}

# Use your existing network module
module "staging_network" {
  source = "../../../modules/network"

  project_id   = var.project_id
  region       = var.region
  environment  = "staging"
  subnet_cidr  = "10.1.1.0/24"
  
  tags = {
    environment = "staging"
    managed_by  = "terraform"
    auth_method = "impersonation"
  }
}

# Simple VM for testing
resource "google_compute_instance" "staging_vm" {
  name         = "staging-vm"
  machine_type = "e2-micro"  # Smaller for cost
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = module.staging_network.vpc_name
    subnetwork = module.staging_network.subnet_name
    
    # No external IP for staging
  }

  service_account {
    email  = "staging-vm-sa@praxis-gear-483220-k4.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  labels = {
    environment = "staging"
    auth_method = "impersonation"
  }
}
```

Create variables file:

```hcl
# Save as: labs/phase-3-impersonation/staging-config/variables.tf

variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "praxis-gear-483220-k4"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-b"
}
```

## 🧪 Step 3: Test Impersonation

```bash
# 1. Navigate to staging config
cd labs/phase-3-impersonation/staging-config

# 2. Initialize Terraform
terraform init

# 3. Plan with impersonation (this will use your user account to impersonate the service account)
terraform plan

# 4. Apply the staging infrastructure
terraform apply -auto-approve

# 5. Verify what identity was used
terraform console
# In console: data.google_client_config.current
```

**What's happening behind the scenes:**
1. Terraform uses your ADC credentials
2. Requests impersonation of `staging-terraform-sa`
3. GCP validates you have `serviceAccountTokenCreator` role
4. GCP issues temporary token for the service account
5. Terraform uses that token for all API calls

## 🔍 Step 4: Audit Trail Analysis

Let's examine the audit trail that impersonation provides:

```bash
# 1. Check Cloud Audit Logs for impersonation events
gcloud logging read "protoPayload.methodName=GenerateAccessToken" \
    --limit=5 \
    --format="table(timestamp,protoPayload.authenticationInfo.principalEmail,protoPayload.request.name)"

# 2. Check who accessed what resources
gcloud logging read "protoPayload.authenticationInfo.principalEmail=staging-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" \
    --limit=10 \
    --format="table(timestamp,protoPayload.methodName,protoPayload.resourceName)"

# 3. Check impersonation requests
gcloud logging read "protoPayload.request.name:staging-terraform-sa" \
    --limit=5 \
    --format="table(timestamp,protoPayload.authenticationInfo.principalEmail,protoPayload.methodName)"
```

**Key Observations:**
- You can see WHO requested impersonation
- You can see WHEN impersonation occurred
- You can see WHAT the impersonated account did
- Full chain of custody for all actions

## 🏢 Step 5: Enterprise Patterns

### **Pattern 1: Environment-Specific Access**

Create different service accounts for different environments:

```bash
# Create production service account (no access for now)
gcloud iam service-accounts create prod-terraform-sa \
    --display-name="Production Terraform Service Account" \
    --description="Service account for production Terraform operations" \
    --project=praxis-gear-483220-k4

# Grant production permissions (more restrictive)
gcloud projects add-iam-policy-binding praxis-gear-483220-k4 \
    --member="serviceAccount:prod-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" \
    --role="roles/compute.viewer"  # Read-only for now

# DON'T grant impersonation permissions yet (production requires approval)
echo "Production access requires approval process"
```

### **Pattern 2: Role-Based Access Control**

```bash
# Create different roles for different team members
gcloud iam roles create staging.terraform.operator \
    --project=praxis-gear-483220-k4 \
    --title="Staging Terraform Operator" \
    --description="Can impersonate staging terraform service account" \
    --permissions="iam.serviceAccounts.actAs,iam.serviceAccounts.getAccessToken"

# Grant role to specific users
gcloud iam service-accounts add-iam-policy-binding \
    staging-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com \
    --member="user:rksuraj@learningmyway.space" \
    --role="projects/praxis-gear-483220-k4/roles/staging.terraform.operator"
```

### **Pattern 3: Time-Limited Access**

Create a script for temporary access:

```powershell
# Save as: labs/phase-3-impersonation/request-prod-access.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$Reason,
    
    [Parameter(Mandatory=$false)]
    [int]$Hours = 2
)

Write-Host "Requesting temporary production access..." -ForegroundColor Yellow
Write-Host "Reason: $Reason"
Write-Host "Duration: $Hours hours"

# In real enterprise, this would:
# 1. Create approval ticket
# 2. Notify managers
# 3. Grant temporary access
# 4. Set automatic revocation

# For demo, we'll simulate the approval
Write-Host "Simulating approval process..." -ForegroundColor Green

# Grant temporary impersonation access
gcloud iam service-accounts add-iam-policy-binding \
    prod-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com \
    --member="user:rksuraj@learningmyway.space" \
    --role="roles/iam.serviceAccountTokenCreator"

Write-Host "✅ Temporary access granted for $Hours hours" -ForegroundColor Green
Write-Host "⏰ Access will be automatically revoked at: $((Get-Date).AddHours($Hours))"

# Schedule revocation (in real system, this would be automated)
Write-Host "⚠️  Remember to revoke access manually after use!" -ForegroundColor Red
```

## 🎯 Step 6: Cross-Environment Deployment Scenario

Let's simulate a real enterprise workflow:

```bash
# 1. Developer works in dev (current setup - ADC)
cd C:\GCP-Terraform-7th-Jan-2026
terraform plan -var-file="environments/dev/terraform.tfvars"

# 2. Deploy to staging (impersonation)
cd labs/phase-3-impersonation/staging-config
terraform plan

# 3. Attempt production access (should fail)
# This demonstrates proper access controls
```

Create a deployment script:

```powershell
# Save as: labs/phase-3-impersonation/deploy-pipeline.ps1

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "staging", "prod")]
    [string]$Environment
)

Write-Host "=== Deployment Pipeline ===" -ForegroundColor Green
Write-Host "Target Environment: $Environment"

switch ($Environment) {
    "dev" {
        Write-Host "Using ADC for development deployment..." -ForegroundColor Blue
        Set-Location "C:\GCP-Terraform-7th-Jan-2026"
        terraform plan -var-file="environments/dev/terraform.tfvars"
    }
    
    "staging" {
        Write-Host "Using impersonation for staging deployment..." -ForegroundColor Yellow
        Set-Location "labs/phase-3-impersonation/staging-config"
        terraform plan
    }
    
    "prod" {
        Write-Host "Checking production access..." -ForegroundColor Red
        
        # Check if user has production impersonation rights
        $hasAccess = gcloud iam service-accounts get-iam-policy \
            prod-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com \
            --format="value(bindings[].members)" | Select-String "user:rksuraj@learningmyway.space"
        
        if ($hasAccess) {
            Write-Host "✅ Production access confirmed" -ForegroundColor Green
            # Would deploy to production here
        } else {
            Write-Host "❌ Production access denied. Request approval first." -ForegroundColor Red
            Write-Host "Run: .\request-prod-access.ps1 -Reason 'Emergency fix for issue #123'"
        }
    }
}
```

## 🧪 Step 7: Advanced Impersonation Scenarios

### **Scenario 1: Chained Impersonation**

Sometimes you need to impersonate through multiple service accounts:

```bash
# Create intermediate service account
gcloud iam service-accounts create intermediate-sa \
    --display-name="Intermediate Service Account" \
    --project=praxis-gear-483220-k4

# Grant intermediate SA ability to impersonate final SA
gcloud iam service-accounts add-iam-policy-binding \
    staging-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com \
    --member="serviceAccount:intermediate-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountTokenCreator"

# Grant user ability to impersonate intermediate SA
gcloud iam service-accounts add-iam-policy-binding \
    intermediate-sa@praxis-gear-483220-k4.iam.gserviceaccount.com \
    --member="user:rksuraj@learningmyway.space" \
    --role="roles/iam.serviceAccountTokenCreator"
```

### **Scenario 2: Conditional Impersonation**

Using IAM Conditions for time-based or IP-based access:

```bash
# Create conditional binding (time-based)
gcloud iam service-accounts add-iam-policy-binding \
    staging-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com \
    --member="user:rksuraj@learningmyway.space" \
    --role="roles/iam.serviceAccountTokenCreator" \
    --condition='expression=request.time.getHours() >= 9 && request.time.getHours() <= 17,title=Business Hours Only,description=Only allow impersonation during business hours'
```

## 📊 Comparison: Impersonation vs Other Methods

| Aspect | ADC | Service Account Keys | **Impersonation** | WIF |
|--------|-----|---------------------|-------------------|-----|
| **Security** | ⭐⭐ | ⭐ | **⭐⭐⭐⭐** | ⭐⭐⭐⭐⭐ |
| **Audit Trail** | Limited | Limited | **Full** | Full |
| **Access Control** | User-based | Key-based | **Role-based** | Attribute-based |
| **Key Management** | None | Manual | **None** | None |
| **Enterprise Ready** | ❌ | ❌ | **✅** | ✅ |
| **Cross-Environment** | ❌ | ⭐ | **✅** | ✅ |

## 🎓 Technical Questions & Answers

**Q: How does service account impersonation work and what are its benefits?**

**A**: Service account impersonation allows one identity to temporarily act as another service account without having access to the service account's private key. The process involves: 1) User authenticates with their own credentials, 2) Requests impersonation of target service account, 3) GCP validates the user has serviceAccountTokenCreator role, 4) GCP issues temporary access token for the service account. Benefits include: no key management, full audit trail showing who impersonated when, time-limited access tokens, centralized permission management, and easy access revocation.

**Q: What's the difference between impersonation and using service account keys?**

**A**: Key differences: 1) **Keys**: Long-lived credentials stored as files, manual rotation required, limited audit trail, high compromise risk. 2) **Impersonation**: No stored credentials, automatic 1-hour token expiration, full audit trail showing both the impersonator and impersonated account, immediate access revocation capability. Impersonation provides better security, auditability, and operational control.

**Q: How would you implement cross-environment access using impersonation?**

**A**: Create environment-specific service accounts (dev-terraform-sa, staging-terraform-sa, prod-terraform-sa) with appropriate permissions for each environment. Grant users impersonation rights based on their role - developers get dev/staging access, senior engineers get production access with approval workflows. Use IAM conditions for time-based or IP-based restrictions. Implement audit logging and regular access reviews. This provides secure, auditable, and manageable cross-environment access.

## 🧹 Cleanup

```bash
# 1. Destroy staging infrastructure
cd labs/phase-3-impersonation/staging-config
terraform destroy -auto-approve

# 2. Remove impersonation permissions (keep service accounts for learning)
gcloud iam service-accounts remove-iam-policy-binding \
    staging-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com \
    --member="user:rksuraj@learningmyway.space" \
    --role="roles/iam.serviceAccountTokenCreator"

# 3. Return to main project
cd C:\GCP-Terraform-7th-Jan-2026

# 4. Verify main infrastructure still works
terraform plan -var-file="environments/dev/terraform.tfvars"
```

## ✅ Phase 3 Completion Checklist

- [ ] Created service accounts for impersonation
- [ ] Successfully deployed infrastructure using impersonation
- [ ] Analyzed audit trails and logging
- [ ] Implemented enterprise access patterns
- [ ] Tested cross-environment deployment scenarios
- [ ] Understand when to use impersonation vs other methods

## 🚀 Next Steps

**Key Takeaways**:
- Impersonation eliminates key management entirely
- Provides full audit trail and access control
- Enables secure cross-environment patterns
- Enterprise-ready with proper governance

**Ready for Phase 4?**  
Now let's explore Workload Identity Federation - the ultimate solution for external systems and CI/CD pipelines.

**Continue to**: [Phase 4 - Workload Identity Federation](../phase-4-workload-identity/README.md)

---

**🎉 Phase 3 Complete!** You now understand enterprise-grade authentication patterns and can implement secure cross-environment access controls.