# 🌐 Phase 4: Workload Identity Federation - The Ultimate Solution

**Duration**: 1.5 hours  
**Difficulty**: ⭐⭐⭐⭐ Expert  
**Security Level**: ⭐⭐⭐⭐⭐ Maximum Security

## 🎯 Learning Objectives

By the end of this phase, you'll understand:
- How Workload Identity Federation eliminates all stored keys
- Setting up GitHub Actions with keyless authentication
- Multi-cloud integration (AWS, Azure)
- Advanced WIF scenarios and troubleshooting
- Enterprise WIF deployment patterns

## 🏗️ What We'll Build

We'll implement a complete CI/CD pipeline using WIF:
- **GitHub Actions**: Keyless deployment to GCP
- **Multi-Environment**: Dev/Staging/Prod with different WIF pools
- **Security Controls**: Attribute-based access control
- **Monitoring**: Complete audit trail and alerting

## 🌟 Why Workload Identity Federation?

### **The Problem WIF Solves**
- ❌ No more service account keys to manage
- ❌ No more secrets in CI/CD systems
- ❌ No more credential rotation headaches
- ❌ No more "who has access to what" confusion

### **The WIF Solution**
- ✅ External systems use their native identity tokens
- ✅ GCP exchanges these for short-lived GCP tokens
- ✅ Fine-grained attribute-based access control
- ✅ Complete audit trail of all access

## 🛠️ Step 1: Analyze Your Existing WIF Setup

Your project already has WIF configured! Let's examine it:
```bash
# 1. Check existing WIF pools
gcloud iam workload-identity-pools list --location=global

# 2. Check your dev pool details
gcloud iam workload-identity-pools describe dev-pool --location=global

# 3. Check providers (should be empty since github_repository is not set)
gcloud iam workload-identity-pools providers list \
    --workload-identity-pool=dev-pool \
    --location=global
```

**Current State**: WIF infrastructure exists but GitHub provider is not active because `github_repository` variable is empty.

## 🔧 Step 2: Set Up GitHub Repository

First, let's prepare your GitHub repository for WIF:

```bash
# 1. Check if you have a GitHub repo for this project
# If not, create one at https://github.com/new

# 2. Update your terraform.tfvars to enable WIF
# Edit environments/dev/terraform.tfvars and set:
# github_repository = "your-username/your-repo-name"
```

Let's update the dev environment to enable WIF:

```bash
# Navigate to your project root
cd C:\GCP-Terraform-7th-Jan-2026

# Create a backup of current tfvars
Copy-Item "environments/dev/terraform.tfvars" "environments/dev/terraform.tfvars.backup"
```

Update your `environments/dev/terraform.tfvars`:

```hcl
# Add this line (replace with your actual GitHub repo)
github_repository = "surajkmr39-lang/GCP-Terraform"  # Update this!

# Keep all other existing values...
project_id = "praxis-gear-483220-k4"
region     = "us-central1"
# ... rest of your config
```

## 🚀 Step 3: Deploy WIF Infrastructure

```bash
# 1. Apply the updated configuration to create GitHub provider
terraform plan -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars"

# 2. Verify WIF provider creation
gcloud iam workload-identity-pools providers list \
    --workload-identity-pool=dev-pool \
    --location=global

# 3. Get the provider details for GitHub Actions
gcloud iam workload-identity-pools providers describe github-provider \
    --workload-identity-pool=dev-pool \
    --location=global \
    --format="value(name)"
```

## 📋 Step 4: Create GitHub Actions Workflow

Create the GitHub Actions workflow directory and files:

```bash
# Create .github/workflows directory
mkdir -p .github/workflows
```

Create the main deployment workflow:

```yaml
# Save as: .github/workflows/deploy-infrastructure.yml

name: Deploy GCP Infrastructure

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:  # Allow manual triggers

env:
  PROJECT_ID: praxis-gear-483220-k4
  WIF_PROVIDER: projects/123456789/locations/global/workloadIdentityPools/dev-pool/providers/github-provider
  SERVICE_ACCOUNT: dev-vm-sa@praxis-gear-483220-k4.iam.gserviceaccount.com

jobs:
  deploy-dev:
    if: github.ref == 'refs/heads/develop' || github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    environment: development
    
    permissions:
      contents: read
      id-token: write  # Required for WIF
      
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Authenticate to Google Cloud
      uses: google-github-actions/auth@v2
      with:
        workload_identity_provider: ${{ env.WIF_PROVIDER }}
        service_account: ${{ env.SERVICE_ACCOUNT }}
        
    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v2
      
    - name: Verify authentication
      run: |
        gcloud auth list
        gcloud config get-value project
        
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.5.0
        
    - name: Terraform Init
      run: terraform init
      
    - name: Terraform Plan
      run: terraform plan -var-file="environments/dev/terraform.tfvars"
      
    - name: Terraform Apply (on main branch)
      if: github.ref == 'refs/heads/develop'
      run: terraform apply -auto-approve -var-file="environments/dev/terraform.tfvars"

  deploy-staging:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: staging
    needs: []  # No dependency on dev for main branch
    
    permissions:
      contents: read
      id-token: write
      
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    # Note: Would use different WIF provider for staging
    - name: Authenticate to Google Cloud
      uses: google-github-actions/auth@v2
      with:
        workload_identity_provider: ${{ env.WIF_PROVIDER }}  # In real setup, different provider
        service_account: ${{ env.SERVICE_ACCOUNT }}  # In real setup, different SA
        
    - name: Deploy to Staging
      run: |
        echo "Would deploy to staging environment"
        echo "Using staging-specific WIF provider and service account"
```

## 🔍 Step 5: Understanding WIF Configuration

Let's examine what your Terraform created:

```bash
# 1. Get the full WIF provider name
terraform output -raw workload_identity_provider_name

# 2. Check the attribute mapping
gcloud iam workload-identity-pools providers describe github-provider \
    --workload-identity-pool=dev-pool \
    --location=global \
    --format="yaml(attributeMapping,attributeCondition)"

# 3. Check service account IAM bindings
gcloud iam service-accounts get-iam-policy \
    dev-vm-sa@praxis-gear-483220-k4.iam.gserviceaccount.com
```

**Key Components**:
- **Workload Identity Pool**: Container for external identities
- **Provider**: Maps GitHub tokens to GCP identities  
- **Attribute Mapping**: Maps GitHub token claims to GCP attributes
- **Attribute Condition**: Restricts access to specific repositories
- **IAM Binding**: Grants impersonation rights to external identities

## 🧪 Step 6: Test WIF Locally (Simulation)

We can simulate WIF behavior locally:

```bash
# 1. Create a test script to understand token exchange
# Save as: labs/phase-4-workload-identity/test-wif-simulation.ps1

Write-Host "=== WIF Token Exchange Simulation ===" -ForegroundColor Green

# Simulate GitHub token (in real GitHub Actions, this is automatic)
$githubToken = @{
    "iss" = "https://token.actions.githubusercontent.com"
    "sub" = "repo:surajkmr39-lang/GCP-Terraform:ref:refs/heads/main"
    "aud" = "https://github.com/surajkmr39-lang"
    "repository" = "surajkmr39-lang/GCP-Terraform"
    "ref" = "refs/heads/main"
    "actor" = "surajkmr39-lang"
}

Write-Host "1. GitHub provides OIDC token with claims:" -ForegroundColor Yellow
$githubToken | ConvertTo-Json -Depth 2

Write-Host "`n2. WIF Provider maps these claims:" -ForegroundColor Yellow
Write-Host "   google.subject = assertion.sub"
Write-Host "   attribute.repository = assertion.repository"
Write-Host "   attribute.ref = assertion.ref"
Write-Host "   attribute.actor = assertion.actor"

Write-Host "`n3. Attribute condition checks:" -ForegroundColor Yellow
Write-Host "   assertion.repository == 'surajkmr39-lang/GCP-Terraform'"

Write-Host "`n4. If conditions pass, GCP issues access token for:" -ForegroundColor Yellow
Write-Host "   Service Account: dev-vm-sa@praxis-gear-483220-k4.iam.gserviceaccount.com"

Write-Host "`n5. GitHub Actions can now access GCP resources!" -ForegroundColor Green
```

## 🏢 Step 7: Enterprise Multi-Environment WIF

Let's create a complete enterprise setup with separate WIF pools:

```bash
# Create staging WIF pool
gcloud iam workload-identity-pools create staging-pool \
    --location=global \
    --display-name="Staging Workload Identity Pool" \
    --description="WIF pool for staging environment"

# Create staging GitHub provider
gcloud iam workload-identity-pools providers create-oidc github-staging \
    --workload-identity-pool=staging-pool \
    --location=global \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.ref=assertion.ref,attribute.actor=assertion.actor" \
    --attribute-condition="assertion.repository == 'surajkmr39-lang/GCP-Terraform' && assertion.ref == 'refs/heads/main'"

# Create production WIF pool (more restrictive)
gcloud iam workload-identity-pools create prod-pool \
    --location=global \
    --display-name="Production Workload Identity Pool" \
    --description="WIF pool for production environment"

# Production provider with stricter conditions
gcloud iam workload-identity-pools providers create-oidc github-prod \
    --workload-identity-pool=prod-pool \
    --location=global \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.ref=assertion.ref,attribute.actor=assertion.actor" \
    --attribute-condition="assertion.repository == 'surajkmr39-lang/GCP-Terraform' && assertion.ref == 'refs/heads/main' && assertion.actor == 'surajkmr39-lang'"
```

## 🔐 Step 8: Advanced WIF Security Patterns

### **Pattern 1: Branch-Based Access Control**

```bash
# Different providers for different branches
gcloud iam workload-identity-pools providers create-oidc github-feature \
    --workload-identity-pool=dev-pool \
    --location=global \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.ref=assertion.ref" \
    --attribute-condition="assertion.repository == 'surajkmr39-lang/GCP-Terraform' && assertion.ref.startsWith('refs/heads/feature/')"
```

### **Pattern 2: User-Based Access Control**

```bash
# Only specific users can deploy to production
gcloud iam workload-identity-pools providers create-oidc github-prod-restricted \
    --workload-identity-pool=prod-pool \
    --location=global \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.actor" \
    --attribute-condition="assertion.repository == 'surajkmr39-lang/GCP-Terraform' && (assertion.actor == 'senior-dev-1' || assertion.actor == 'senior-dev-2')"
```

### **Pattern 3: Time-Based Access Control**

```bash
# Only allow deployments during business hours
# (This would be implemented in IAM conditions on the service account binding)
gcloud iam service-accounts add-iam-policy-binding \
    prod-terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com \
    --member="principalSet://iam.googleapis.com/projects/praxis-gear-483220-k4/locations/global/workloadIdentityPools/prod-pool/attribute.repository/surajkmr39-lang/GCP-Terraform" \
    --role="roles/iam.workloadIdentityUser" \
    --condition='expression=request.time.getHours() >= 9 && request.time.getHours() <= 17,title=Business Hours Only,description=Production deployments only during business hours'
```

## 🌐 Step 9: Multi-Cloud WIF Integration

WIF can integrate with other cloud providers:

### **AWS Integration Example**

```bash
# Create AWS provider (example - would need actual AWS setup)
gcloud iam workload-identity-pools providers create-aws aws-provider \
    --workload-identity-pool=dev-pool \
    --location=global \
    --account-id="123456789012" \
    --attribute-mapping="google.subject=assertion.arn,attribute.aws_role=assertion.arn.contains('role')" \
    --attribute-condition="assertion.arn.startsWith('arn:aws:sts::123456789012:assumed-role/MyRole/')"
```

### **Azure Integration Example**

```bash
# Create Azure provider (example)
gcloud iam workload-identity-pools providers create-oidc azure-provider \
    --workload-identity-pool=dev-pool \
    --location=global \
    --issuer-uri="https://login.microsoftonline.com/TENANT-ID/v2.0" \
    --attribute-mapping="google.subject=assertion.sub,attribute.tenant=assertion.tid" \
    --attribute-condition="assertion.tid == 'your-azure-tenant-id'"
```

## 📊 Step 10: Monitoring and Alerting

Set up monitoring for WIF usage:

```bash
# Create log-based metric for WIF token exchanges
gcloud logging metrics create wif_token_exchanges \
    --description="Count of WIF token exchanges" \
    --log-filter='protoPayload.methodName="GenerateAccessToken" AND protoPayload.request.name:workloadIdentityPools'

# Create alerting policy
gcloud alpha monitoring policies create \
    --policy-from-file=labs/phase-4-workload-identity/wif-monitoring-policy.yaml
```

Create monitoring policy:

```yaml
# Save as: labs/phase-4-workload-identity/wif-monitoring-policy.yaml
displayName: "WIF Token Exchange Monitoring"
conditions:
  - displayName: "High WIF Token Exchange Rate"
    conditionThreshold:
      filter: 'resource.type="global" AND metric.type="logging.googleapis.com/user/wif_token_exchanges"'
      comparison: COMPARISON_GREATER_THAN
      thresholdValue: 100
      duration: 300s
alertStrategy:
  autoClose: 86400s
enabled: true
```

## 🎓 Technical Questions & Answers

**Q: How does Workload Identity Federation eliminate the need for service account keys?**

**A**: WIF allows external workloads to exchange their native identity tokens (like GitHub OIDC tokens, AWS credentials, or Azure tokens) for short-lived Google Cloud access tokens. The process: 1) External system authenticates with its native identity provider, 2) Presents identity token to GCP WIF endpoint, 3) GCP validates the token and checks attribute conditions, 4) If valid, GCP issues a short-lived access token for the configured service account. This eliminates stored keys because the external system uses its own identity mechanism rather than storing GCP credentials.

**Q: What are the key components of a WIF setup and how do they work together?**

**A**: Key components: 1) **Workload Identity Pool**: Container that manages external identities for a project, 2) **Provider**: Specific configuration for each external identity system (GitHub, AWS, Azure), defines token validation and attribute mapping, 3) **Attribute Mapping**: Maps external token claims to GCP attributes (e.g., GitHub repository to google.subject), 4) **Attribute Conditions**: Boolean expressions that restrict access based on token attributes, 5) **IAM Bindings**: Grant the external identity permission to impersonate specific service accounts. These work together to create a secure, auditable authentication flow.

**Q: How would you implement environment-specific access control with WIF?**

**A**: Create separate WIF pools and providers for each environment with different attribute conditions: 1) **Dev Pool**: Allow any branch, any developer, 2) **Staging Pool**: Only main branch, specific repositories, 3) **Production Pool**: Only main branch, specific users, business hours only. Use different service accounts per environment with appropriate permissions. Implement branch-based conditions (refs/heads/main vs refs/heads/develop), user-based conditions (specific GitHub actors), and time-based conditions (business hours). This provides fine-grained, auditable access control without any stored credentials.

## 🧹 Cleanup

```bash
# 1. Remove GitHub repository setting (to avoid accidental deployments)
# Edit environments/dev/terraform.tfvars and set github_repository = ""

# 2. Apply to remove GitHub provider
terraform apply -var-file="environments/dev/terraform.tfvars"

# 3. Clean up additional WIF pools (keep for learning)
# gcloud iam workload-identity-pools delete staging-pool --location=global
# gcloud iam workload-identity-pools delete prod-pool --location=global
```

## ✅ Phase 4 Completion Checklist

- [ ] Activated existing WIF infrastructure
- [ ] Created GitHub Actions workflow with keyless authentication
- [ ] Implemented multi-environment WIF patterns
- [ ] Set up advanced security controls and monitoring
- [ ] Understand enterprise WIF deployment strategies
- [ ] Can explain WIF benefits and implementation in presentations

## 🏆 Lab Series Completion

**🎉 Congratulations!** You've completed all 4 phases of GCP authentication mastery:

### **What You've Accomplished**
- ✅ **Phase 1**: Mastered Application Default Credentials
- ✅ **Phase 2**: Understood service account keys and their risks
- ✅ **Phase 3**: Implemented enterprise-grade impersonation patterns
- ✅ **Phase 4**: Deployed keyless authentication with Workload Identity Federation

### **Skills Gained**
- Complete understanding of all GCP authentication methods
- Enterprise security patterns and best practices
- Hands-on experience with real-world scenarios
- Professional-ready knowledge and practical examples
- Troubleshooting and monitoring capabilities

### **Portfolio Value**
This lab series demonstrates:
- **Security Expertise**: Understanding of modern authentication patterns
- **Enterprise Experience**: Real-world deployment scenarios
- **DevOps Skills**: CI/CD integration and automation
- **Cloud Architecture**: Multi-environment, multi-cloud patterns

---

**🚀 You're now a GCP Authentication Expert!**  
**Ready to tackle any enterprise authentication challenge!**