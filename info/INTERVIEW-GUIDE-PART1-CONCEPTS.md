# 📖 Interview Guide Part 1: Core Concepts

## 🎯 **Terraform Fundamentals**

### **What is Terraform?**
Terraform is an Infrastructure as Code (IaC) tool that allows you to define, provision, and manage cloud infrastructure using declarative configuration files. It uses HashiCorp Configuration Language (HCL) to describe infrastructure resources.

### **Key Terraform Concepts:**

**1. Resources:**
```hcl
resource "google_compute_instance" "vm" {
  name         = "development-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
}
```

**2. Variables:**
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}
```

**3. Outputs:**
```hcl
output "vm_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}
```

**4. Modules:**
```hcl
module "network" {
  source = "./modules/network"
  environment = var.environment
}
```

## 🏗️ **Infrastructure as Code Principles**

### **Why IaC?**
- **Version Control**: Infrastructure changes tracked in Git
- **Reproducibility**: Same configuration creates identical infrastructure
- **Collaboration**: Teams can work together on infrastructure
- **Automation**: Infrastructure deployment through CI/CD
- **Documentation**: Code serves as living documentation

### **IaC Benefits in Our Project:**
- ✅ **Multi-environment consistency**: Same code deploys to dev/staging/prod
- ✅ **Change tracking**: All infrastructure changes in Git history
- ✅ **Rollback capability**: Can revert to previous infrastructure state
- ✅ **Team collaboration**: Multiple developers can contribute
- ✅ **Automated deployment**: CI/CD pipelines deploy infrastructure

## 💾 **State Management Concepts**

### **What is Terraform State?**
Terraform state is a file that maps your configuration to real-world resources. It tracks metadata and enables Terraform to know what exists and how to modify it.

### **Local vs Remote State:**

**Local State:**
```bash
# Stored locally
terraform.tfstate
terraform.tfstate.backup
```
- ✅ Simple for individual development
- ❌ No team collaboration
- ❌ No backup/versioning
- ❌ Risk of state loss

**Remote State (Our Approach):**
```hcl
terraform {
  backend "gcs" {
    bucket = "praxis-gear-483220-k4-terraform-state"
    prefix = "environments/development/terraform-state"
  }
}
```
- ✅ Team collaboration enabled
- ✅ Automatic state locking
- ✅ Built-in versioning and backup
- ✅ High availability

### **State Locking:**
Prevents multiple users from modifying infrastructure simultaneously, avoiding conflicts and corruption.

## 🌍 **Multi-Environment Strategy**

### **Environment Separation Approaches:**

**1. Workspace-based (Not Recommended for Production):**
```bash
terraform workspace new development
terraform workspace new production
```

**2. Directory-based (Our Approach):**
```
environments/
├── dev/
├── staging/
└── prod/
```

### **Why Directory-based?**
- ✅ **Complete isolation**: Separate state files
- ✅ **Environment-specific configurations**: Different variables per environment
- ✅ **Independent deployments**: Deploy environments separately
- ✅ **Reduced blast radius**: Issues in one environment don't affect others
- ✅ **Clear organization**: Easy to understand and maintain

### **Our Multi-Environment Setup:**
```yaml
Development:
  - CIDR: 10.10.0.0/16
  - Machine: e2-medium
  - Disk: 30GB
  - Cost: $18-24/month

Staging:
  - CIDR: 10.20.0.0/16
  - Machine: e2-standard-2
  - Disk: 50GB
  - Cost: $25-35/month

Production:
  - CIDR: 10.30.0.0/16
  - Machine: e2-standard-4
  - Disk: 100GB
  - Cost: $45-60/month
```

## 🔐 **Security Concepts**

### **Workload Identity Federation (WIF):**
Modern authentication method that eliminates the need for stored service account keys.

**Traditional Approach (Insecure):**
```yaml
# Service account key stored in GitHub Secrets
- name: Authenticate
  env:
    GOOGLE_APPLICATION_CREDENTIALS: ${{ secrets.GCP_SA_KEY }}
```

**WIF Approach (Secure):**
```yaml
# Keyless authentication using OIDC tokens
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v1
  with:
    workload_identity_provider: projects/.../workloadIdentityPools/github-pool/providers/github
    service_account: galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com
```

### **Security Benefits:**
- ✅ **No stored credentials**: Zero service account keys
- ✅ **Short-lived tokens**: Automatic expiration
- ✅ **Attribute-based access**: Repository/branch restrictions
- ✅ **Complete audit trail**: All authentication events logged

## 📦 **Module Architecture**

### **Why Use Modules?**
- **Reusability**: Write once, use multiple times
- **Organization**: Logical grouping of resources
- **Abstraction**: Hide complexity behind simple interfaces
- **Testing**: Test modules independently

### **Our Module Structure:**
```
modules/
├── network/     # VPC, subnets, NAT gateway
├── security/    # Firewall rules, IAM policies
├── iam/         # Service accounts, WIF setup
└── compute/     # VM instances, disks
```

### **Module Benefits:**
- ✅ **Separation of concerns**: Each module has specific responsibility
- ✅ **Reusable across environments**: Same modules, different variables
- ✅ **Easier testing**: Test individual components
- ✅ **Team ownership**: Different teams can own different modules

## 🔄 **Terraform Workflow**

### **Standard Workflow:**
```bash
1. terraform init     # Initialize working directory
2. terraform plan     # Preview changes
3. terraform apply    # Apply changes
4. terraform destroy  # Clean up resources
```

### **Our Enterprise Workflow:**
```bash
# Environment-specific workflow
cd environments/development
terraform init
terraform plan
terraform apply

# Multi-environment deployment
for env in dev staging prod; do
  cd environments/$env
  terraform init
  terraform plan
  terraform apply
done
```

## 🎯 **Common Interview Questions & Answers**

### **Q: "What is Terraform and why would you use it?"**
**A:** "Terraform is an Infrastructure as Code tool that lets you define cloud infrastructure using declarative configuration files. I use it because it provides version control for infrastructure, enables team collaboration, ensures consistency across environments, and allows automated deployments through CI/CD pipelines."

### **Q: "Explain the difference between local and remote state."**
**A:** "Local state is stored on your local machine, which works for individual development but doesn't support team collaboration or provide backup. Remote state is stored in a backend like GCS, enabling team collaboration with state locking, automatic backups, and high availability. In my project, I use remote state with GCS for all environments."

### **Q: "How do you manage multiple environments with Terraform?"**
**A:** "I use a directory-based approach with separate folders for each environment. Each environment has its own state file, configuration, and variables. This provides complete isolation, allows environment-specific settings, and reduces the blast radius of changes. My setup has development, staging, and production environments with different resource sizing."

### **Q: "What is Workload Identity Federation and why is it important?"**
**A:** "WIF is Google Cloud's keyless authentication mechanism that allows external workloads like GitHub Actions to authenticate without storing service account keys. It's important because it eliminates the security risk of stored credentials, provides short-lived tokens, and enables fine-grained access control based on repository attributes."

### **Q: "How do you structure Terraform code for maintainability?"**
**A:** "I use a modular approach with separate modules for different infrastructure components like networking, security, and compute. Each module has a specific responsibility and can be reused across environments. I also use consistent naming conventions, proper variable definitions, and comprehensive documentation."

### **Q: "What are the benefits of Infrastructure as Code?"**
**A:** "IaC provides version control for infrastructure changes, ensures reproducibility across environments, enables team collaboration, supports automated deployments, and serves as living documentation. It eliminates manual configuration drift and makes infrastructure changes auditable and reversible."

## 📚 **Key Takeaways**

### **Core Concepts to Remember:**
1. **Terraform is declarative** - You describe what you want, not how to get there
2. **State is critical** - It's how Terraform knows what exists
3. **Remote state enables collaboration** - Essential for team environments
4. **Modules promote reusability** - Write once, use everywhere
5. **Multi-environment strategy is crucial** - Separate environments for safety
6. **Security is paramount** - Use WIF, not stored keys
7. **IaC enables automation** - Infrastructure through CI/CD

### **Project Highlights:**
- ✅ Enterprise multi-environment architecture
- ✅ Remote state management with GCS
- ✅ Workload Identity Federation for security
- ✅ Modular, reusable code structure
- ✅ CI/CD integration with GitHub Actions
- ✅ Cost-optimized resource sizing

**Next:** Continue to [Part 2: Code Walkthrough](INTERVIEW-GUIDE-PART2-CODE-WALKTHROUGH.md) to dive deep into the actual implementation details.