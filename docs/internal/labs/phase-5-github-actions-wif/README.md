# 🚀 Phase 5: GitHub Actions with WIF - Complete Integration

**Duration**: 45 minutes  
**Difficulty**: ⭐⭐⭐ Advanced  
**Prerequisites**: Phase 4 completed, WIF infrastructure deployed

## 🎯 What You'll Learn

- How to create GitHub Actions workflows
- Integrating WIF with GitHub Actions
- Testing keyless authentication end-to-end
- Monitoring and troubleshooting workflows
- Real-world CI/CD patterns

## 📋 Current State

You have:
- ✅ WIF Pool: `github-pool` (configured in GCP)
- ✅ GitHub Provider: `github` (configured in GCP)
- ✅ Service Account: `galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com`
- ❌ GitHub Actions Workflow: **NOT YET CREATED**

**This lab completes the missing piece!**

## 🏗️ Understanding the Connection

### The Two Sides of WIF

```
┌──────────────────────┐         ┌──────────────────────┐
│   GCP Side           │         │   GitHub Side        │
│   (You have this)    │         │   (We'll create)     │
├──────────────────────┤         ├──────────────────────┤
│                      │         │                      │
│  WIF Pool            │◄────────┤  GitHub Actions      │
│  GitHub Provider     │  Token  │  Workflow            │
│  Service Account     │ Exchange│  (.github/workflows) │
│                      │         │                      │
└──────────────────────┘         └──────────────────────┘
```

## 🚀 Step 1: Check Your GitHub Repository

First, verify your GitHub repository exists:

```bash
# Check if you have a GitHub repository
# Go to: https://github.com/surajkmr39-lang/GCP-Terraform

# If repository doesn't exist, create it:
# 1. Go to https://github.com/new
# 2. Name: GCP-Terraform
# 3. Make it public or private
# 4. Don't initialize with README (you already have code)
```

## 📁 Step 2: Create GitHub Actions Directory Structure

```bash
# Create the workflows directory
mkdir -p .github/workflows

# Verify it was created
Test-Path .github/workflows
```

## 📝 Step 3: Create Your First WIF Workflow

Let's create a simple test workflow first:

```yaml
# Save as: .github/workflows/test-wif-auth.yml

name: Test WIF Authentication

on:
  workflow_dispatch:  # Manual trigger for testing
  push:
    branches: [ main ]

jobs:
  test-auth:
    name: Test WIF Authentication
    runs-on: ubuntu-latest
    
    # CRITICAL: These permissions are required for WIF
    permissions:
      contents: read
      id-token: write  # This allows GitHub to issue OIDC tokens
      
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v4
      
    - name: Authenticate to Google Cloud using WIF
      id: auth
      uses: google-github-actions/auth@v2
      with:
        # Your WIF provider (from Check-WIF-Status.ps1 output)
        workload_identity_provider: 'projects/251838763754/locations/global/workloadIdentityPools/github-pool/providers/github'
        
        # Your service account
        service_account: 'galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com'
        
    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v2
      
    - name: Verify Authentication
      run: |
        echo "🔐 Testing WIF Authentication..."
        echo ""
        echo "Current authenticated account:"
        gcloud auth list
        echo ""
        echo "Current project:"
        gcloud config get-value project
        echo ""
        echo "✅ WIF Authentication Successful!"
        
    - name: Test GCP Access
      run: |
        echo "🧪 Testing GCP API access..."
        echo ""
        echo "Listing compute instances:"
        gcloud compute instances list --limit=5
        echo ""
        echo "Listing service accounts:"
        gcloud iam service-accounts list --limit=5
        echo ""
        echo "✅ GCP Access Verified!"
```

Create this file:

```bash
# Create the file
New-Item -Path ".github/workflows/test-wif-auth.yml" -ItemType File -Force
```

Now copy the YAML content above into `.github/workflows/test-wif-auth.yml`

## 📝 Step 4: Create Full Terraform Deployment Workflow

Now let's create a complete workflow that deploys infrastructure:

```yaml
# Save as: .github/workflows/deploy-infrastructure.yml

name: Deploy GCP Infrastructure

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

env:
  PROJECT_ID: praxis-gear-483220-k4
  TF_VERSION: 1.5.0

jobs:
  terraform-plan:
    name: Terraform Plan
    runs-on: ubuntu-latest
    
    permissions:
      contents: read
      id-token: write
      pull-requests: write  # To comment on PRs
      
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
      
    - name: Authenticate to GCP with WIF
      uses: google-github-actions/auth@v2
      with:
        workload_identity_provider: 'projects/251838763754/locations/global/workloadIdentityPools/github-pool/providers/github'
        service_account: 'galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com'
        
    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v2
      
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}
        
    - name: Terraform Format Check
      run: terraform fmt -check -recursive
      continue-on-error: true
      
    - name: Terraform Init
      run: terraform init
      
    - name: Terraform Validate
      run: terraform validate
      
    - name: Terraform Plan
      id: plan
      run: |
        terraform plan \
          -var-file="environments/dev/terraform.tfvars" \
          -out=tfplan \
          -no-color
      continue-on-error: true
      
    - name: Comment PR with Plan
      if: github.event_name == 'pull_request'
      uses: actions/github-script@v7
      with:
        script: |
          const output = `#### Terraform Plan 📋
          
          **Status**: ${{ steps.plan.outcome }}
          
          <details><summary>Show Plan</summary>
          
          \`\`\`
          ${{ steps.plan.outputs.stdout }}
          \`\`\`
          
          </details>
          
          *Pushed by: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;
          
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })

  terraform-apply:
    name: Terraform Apply
    runs-on: ubuntu-latest
    needs: terraform-plan
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    permissions:
      contents: read
      id-token: write
      
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
      
    - name: Authenticate to GCP with WIF
      uses: google-github-actions/auth@v2
      with:
        workload_identity_provider: 'projects/251838763754/locations/global/workloadIdentityPools/github-pool/providers/github'
        service_account: 'galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com'
        
    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v2
      
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}
        
    - name: Terraform Init
      run: terraform init
      
    - name: Terraform Apply
      run: |
        terraform apply \
          -var-file="environments/dev/terraform.tfvars" \
          -auto-approve
          
    - name: Deployment Summary
      run: |
        echo "🎉 Deployment completed successfully!"
        echo ""
        echo "📊 Infrastructure deployed using:"
        echo "  - Workload Identity Federation (keyless)"
        echo "  - Service Account: galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com"
        echo "  - No service account keys used or stored"
        echo ""
        terraform output
```

Create this file:

```bash
# Create the file
New-Item -Path ".github/workflows/deploy-infrastructure.yml" -ItemType File -Force
```

## 🔍 Step 5: Verify Workflow Files

```bash
# Check that workflows were created
Get-ChildItem .github/workflows/

# Should show:
# test-wif-auth.yml
# deploy-infrastructure.yml
```

## 📤 Step 6: Push to GitHub

```bash
# Check git status
git status

# Add the workflow files
git add .github/

# Commit
git commit -m "Add GitHub Actions workflows with WIF authentication"

# Push to GitHub
git push origin main
```

## 🧪 Step 7: Test the Workflow

### Option 1: Manual Trigger (Recommended for first test)

1. Go to your GitHub repository: `https://github.com/surajkmr39-lang/GCP-Terraform`
2. Click on **Actions** tab
3. Click on **Test WIF Authentication** workflow
4. Click **Run workflow** button
5. Select branch: `main`
6. Click **Run workflow**

### Option 2: Automatic Trigger

```bash
# Make a small change and push
echo "# Testing WIF" >> README.md
git add README.md
git commit -m "Test WIF workflow trigger"
git push origin main
```

## 📊 Step 8: Monitor the Workflow

### In GitHub:

1. Go to **Actions** tab
2. Click on the running workflow
3. Watch each step execute in real-time
4. Look for:
   - ✅ Checkout Repository
   - ✅ Authenticate to Google Cloud using WIF
   - ✅ Verify Authentication
   - ✅ Test GCP Access

### Expected Output:

```
🔐 Testing WIF Authentication...

Current authenticated account:
                Credentialed Accounts
ACTIVE  ACCOUNT
*       galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com

Current project:
praxis-gear-483220-k4

✅ WIF Authentication Successful!
```

## 🔍 Step 9: Verify in GCP Cloud Logging

Check that WIF token exchanges are happening:

```bash
# View WIF authentication logs
gcloud logging read \
    'protoPayload.methodName="GenerateAccessToken" AND 
     protoPayload.request.name:github-pool' \
    --limit=5 \
    --format="table(timestamp,protoPayload.authenticationInfo.principalEmail,protoPayload.request.name)"
```

You should see entries showing GitHub Actions requesting tokens!

## 🎯 Step 10: Understanding What Just Happened

### The Complete Flow:

```
1. GitHub Actions Workflow Starts
   ↓
2. GitHub Issues OIDC Token
   Token contains:
   - repository: "surajkmr39-lang/GCP-Terraform"
   - ref: "refs/heads/main"
   - actor: "surajkmr39-lang"
   ↓
3. google-github-actions/auth@v2 Action
   Sends OIDC token to GCP WIF endpoint
   ↓
4. GCP Validates Token
   - Checks issuer (GitHub)
   - Validates signature
   - Checks attribute condition (repository match)
   ↓
5. GCP Issues Access Token
   - For service account: galaxy@...
   - Duration: 1 hour
   - Scope: cloud-platform
   ↓
6. GitHub Actions Uses Token
   - Runs gcloud commands
   - Deploys infrastructure
   - All authenticated as service account
   ↓
7. Token Expires Automatically
   No cleanup needed!
```

## 🚨 Troubleshooting

### Issue 1: "Failed to generate access token"

**Check**:
```bash
# Verify WIF provider exists
gcloud iam workload-identity-pools providers describe github \
    --workload-identity-pool=github-pool \
    --location=global \
    --project=praxis-gear-483220-k4
```

**Solution**: Make sure repository name in attribute condition matches exactly

### Issue 2: "Permission denied" in workflow

**Check**:
```bash
# Verify service account has necessary permissions
gcloud projects get-iam-policy praxis-gear-483220-k4 \
    --flatten="bindings[].members" \
    --filter="bindings.members:galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com"
```

**Solution**: Grant required roles to service account

### Issue 3: "id-token: write permission required"

**Solution**: Make sure workflow has:
```yaml
permissions:
  contents: read
  id-token: write  # REQUIRED!
```

## 📚 Advanced Workflows

### Multi-Environment Deployment

```yaml
# Example: Deploy to dev, then staging, then prod
jobs:
  deploy-dev:
    # Deploy to dev environment
    
  deploy-staging:
    needs: deploy-dev
    # Deploy to staging
    
  deploy-prod:
    needs: deploy-staging
    environment: production  # Requires manual approval
    # Deploy to production
```

### Workflow with Approval

```yaml
jobs:
  deploy-prod:
    environment:
      name: production
      url: https://console.cloud.google.com/
    # GitHub will require manual approval before running
```

## ✅ Phase 5 Completion Checklist

- [ ] Created `.github/workflows/` directory
- [ ] Created `test-wif-auth.yml` workflow
- [ ] Created `deploy-infrastructure.yml` workflow
- [ ] Pushed workflows to GitHub
- [ ] Successfully ran test workflow
- [ ] Verified authentication in workflow logs
- [ ] Checked GCP Cloud Logging for token exchanges
- [ ] Understand the complete WIF flow

## 🎉 Success Criteria

You've completed Phase 5 when:
1. ✅ GitHub Actions workflow runs successfully
2. ✅ Authenticates using WIF (no keys!)
3. ✅ Can access GCP resources
4. ✅ Can deploy Terraform infrastructure
5. ✅ See token exchanges in GCP logs

## 🎓 Technical Talking Points

**Q: "Walk me through your CI/CD setup"**

**A**: "I implemented a complete CI/CD pipeline using GitHub Actions with Workload Identity Federation. When code is pushed to main, GitHub Actions triggers a workflow that authenticates to GCP using WIF - no service account keys stored anywhere. The workflow runs terraform plan on pull requests for review, and automatically applies changes when merged to main. We use separate workflows for different environments with approval gates for production."

---

**🚀 You now have a complete end-to-end WIF implementation with GitHub Actions!**

Next: Monitor your workflows and iterate on the deployment process.