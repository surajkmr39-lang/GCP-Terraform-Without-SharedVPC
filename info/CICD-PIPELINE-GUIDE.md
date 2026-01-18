# 🚀 CI/CD Pipeline Guide

## 🎯 **Overview**

Our CI/CD setup demonstrates enterprise-grade automation with GitHub Actions, featuring multi-environment deployments, security scanning, and Workload Identity Federation for keyless authentication.

## 📁 **Pipeline Structure**

### **🔐 Authentication Test** → `.github/workflows/test-wif-auth.yml`
- Tests Workload Identity Federation setup
- Validates service account permissions
- Runs on every push to verify authentication

### **🚀 Infrastructure Deployment** → `.github/workflows/deploy-infrastructure.yml`
- Deploys infrastructure to specific environments
- Supports manual triggers with environment selection
- Includes approval gates for production

### **🔄 Complete CI/CD Pipeline** → `.github/workflows/cicd-pipeline.yml`
- Full end-to-end automation
- Multi-environment deployment workflow
- Security scanning and validation

## 🔐 **Authentication Setup**

### **Workload Identity Federation:**
```yaml
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v1
  with:
    workload_identity_provider: projects/${{ secrets.GCP_PROJECT_NUMBER }}/locations/global/workloadIdentityPools/github-pool/providers/github
    service_account: galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com
```

### **Required Secrets:**
- `GCP_PROJECT_ID`: praxis-gear-483220-k4
- `GCP_PROJECT_NUMBER`: Your project number
- No service account keys needed! 🎉

## 🌍 **Multi-Environment Deployment**

### **Environment Strategy:**
```yaml
strategy:
  matrix:
    environment: [development, staging, production]
    include:
      - environment: development
        terraform_dir: environments/dev
        approval_required: false
      - environment: staging
        terraform_dir: environments/staging
        approval_required: false
      - environment: production
        terraform_dir: environments/prod
        approval_required: true
```

### **Deployment Flow:**
1. **Code Push** → Triggers pipeline
2. **Authentication** → WIF validates GitHub Actions
3. **Security Scan** → Terraform security analysis
4. **Plan Generation** → Creates deployment plan
5. **Approval Gate** → Manual approval for production
6. **Infrastructure Deployment** → Applies changes
7. **Validation** → Verifies deployment success

## 🛡️ **Security Features**

### **Security Scanning:**
```yaml
- name: Run Terraform Security Scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'config'
    scan-ref: '.'
    format: 'sarif'
    output: 'trivy-results.sarif'
```

### **Compliance Checks:**
- Infrastructure security scanning
- Terraform plan validation
- Resource compliance verification
- Cost estimation and alerts

### **Access Controls:**
- Branch protection rules
- Required reviews for production
- Environment-specific approvals
- Audit logging for all operations

## 📊 **Pipeline Stages**

### **Stage 1: Validation**
```yaml
validate:
  runs-on: ubuntu-latest
  steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
    
    - name: Terraform Format Check
      run: terraform fmt -check -recursive
    
    - name: Terraform Validate
      run: terraform validate
```

### **Stage 2: Security Scanning**
```yaml
security:
  runs-on: ubuntu-latest
  needs: validate
  steps:
    - name: Run Security Scan
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'config'
        scan-ref: '.'
    
    - name: Upload Security Results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'
```

### **Stage 3: Plan**
```yaml
plan:
  runs-on: ubuntu-latest
  needs: [validate, security]
  strategy:
    matrix:
      environment: [development, staging, production]
  steps:
    - name: Terraform Plan
      working-directory: environments/${{ matrix.environment }}
      run: |
        terraform init
        terraform plan -out=tfplan
    
    - name: Upload Plan
      uses: actions/upload-artifact@v3
      with:
        name: tfplan-${{ matrix.environment }}
        path: environments/${{ matrix.environment }}/tfplan
```

### **Stage 4: Deploy**
```yaml
deploy:
  runs-on: ubuntu-latest
  needs: plan
  if: github.ref == 'refs/heads/main'
  environment: 
    name: ${{ matrix.environment }}
    url: https://console.cloud.google.com/compute/instances?project=praxis-gear-483220-k4
  steps:
    - name: Download Plan
      uses: actions/download-artifact@v3
      with:
        name: tfplan-${{ matrix.environment }}
        path: environments/${{ matrix.environment }}/
    
    - name: Terraform Apply
      working-directory: environments/${{ matrix.environment }}
      run: terraform apply tfplan
```

## 🔄 **Workflow Triggers**

### **Automatic Triggers:**
```yaml
on:
  push:
    branches: [ main, develop ]
    paths:
      - 'environments/**'
      - 'modules/**'
      - '.github/workflows/**'
  
  pull_request:
    branches: [ main ]
    paths:
      - 'environments/**'
      - 'modules/**'
```

### **Manual Triggers:**
```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'development'
        type: choice
        options:
          - development
          - staging
          - production
      
      action:
        description: 'Action to perform'
        required: true
        default: 'plan'
        type: choice
        options:
          - plan
          - apply
          - destroy
```

## 📈 **Monitoring & Notifications**

### **Slack Integration:**
```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    channel: '#infrastructure'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
    fields: repo,message,commit,author,action,eventName,ref,workflow
```

### **Email Notifications:**
```yaml
- name: Send Email Notification
  if: failure()
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: smtp.gmail.com
    server_port: 587
    username: ${{ secrets.EMAIL_USERNAME }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: "Infrastructure Deployment Failed"
    body: "Deployment to ${{ matrix.environment }} failed. Check the logs for details."
    to: devops-team@company.com
```

## 🎯 **Best Practices Implemented**

### **Security:**
- ✅ Keyless authentication with WIF
- ✅ Security scanning on every commit
- ✅ Secrets management with GitHub Secrets
- ✅ Least privilege access principles

### **Reliability:**
- ✅ Multi-stage validation
- ✅ Approval gates for production
- ✅ Rollback capabilities
- ✅ Comprehensive error handling

### **Observability:**
- ✅ Detailed logging and monitoring
- ✅ Slack/email notifications
- ✅ Deployment status tracking
- ✅ Cost and resource monitoring

### **Efficiency:**
- ✅ Parallel execution where possible
- ✅ Artifact caching and reuse
- ✅ Conditional execution based on changes
- ✅ Matrix builds for multi-environment

## 🚨 **Troubleshooting**

### **Common Issues:**

**1. Authentication Failures:**
```bash
# Check WIF configuration
gcloud iam workload-identity-pools describe github-pool --location=global

# Verify service account permissions
gcloud iam service-accounts get-iam-policy galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com
```

**2. Terraform State Lock:**
```bash
# Force unlock if needed (use carefully)
terraform force-unlock <LOCK_ID>
```

**3. Permission Denied:**
```bash
# Check project IAM bindings
gcloud projects get-iam-policy praxis-gear-483220-k4
```

### **Debug Steps:**
1. Check GitHub Actions logs
2. Verify WIF configuration
3. Validate Terraform syntax
4. Check GCP resource quotas
5. Review IAM permissions

## 📊 **Pipeline Metrics**

### **Key Performance Indicators:**
- **Deployment Success Rate**: Target 95%+
- **Mean Time to Deploy**: Target <10 minutes
- **Mean Time to Recovery**: Target <30 minutes
- **Security Scan Pass Rate**: Target 100%

### **Monitoring Dashboards:**
```yaml
# GitHub Actions metrics
- Workflow run frequency
- Success/failure rates
- Duration trends
- Resource usage

# Infrastructure metrics
- Deployment frequency
- Change failure rate
- Lead time for changes
- Recovery time
```

## 🎪 **Demo Script**

### **Live Demonstration:**
```bash
# 1. Show workflow files
ls -la .github/workflows/

# 2. Explain WIF authentication
cat .github/workflows/cicd-pipeline.yml | grep -A 10 "google-github-actions/auth"

# 3. Trigger manual deployment
# (Show in GitHub Actions UI)

# 4. Monitor deployment progress
# (Show logs in GitHub Actions)

# 5. Verify infrastructure
terraform state list
gcloud compute instances list
```

**Talking Points:**
- "This demonstrates enterprise CI/CD practices"
- "Notice the keyless authentication - no stored credentials"
- "Multi-environment deployment with approval gates"
- "Security scanning integrated into the pipeline"
- "Complete audit trail and monitoring"

## 🏆 **Interview Questions & Answers**

### **Q: "How do you implement CI/CD for infrastructure?"**
**A:** "I use GitHub Actions with a multi-stage pipeline that includes validation, security scanning, planning, and deployment. The key is treating infrastructure as code with the same rigor as application code - automated testing, code reviews, and controlled deployments with approval gates for production."

### **Q: "How do you handle secrets in CI/CD pipelines?"**
**A:** "I use Workload Identity Federation to eliminate stored secrets entirely. GitHub Actions authenticates to GCP using OIDC tokens, which are temporary and automatically managed. This is much more secure than storing service account keys in GitHub Secrets."

### **Q: "How do you ensure deployment safety?"**
**A:** "I implement multiple safety measures: terraform plan review before apply, security scanning on every commit, approval gates for production deployments, and the ability to rollback changes. Each environment is isolated with separate state files and configurations."

This CI/CD setup demonstrates modern DevOps practices and enterprise-grade automation! 🚀