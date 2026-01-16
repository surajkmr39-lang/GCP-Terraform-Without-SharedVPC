# Infrastructure Setup Guide

**Author**: Suraj Kumar

## Prerequisites Checklist

### 1. Google Cloud Setup
- [ ] Create or select a GCP project
- [ ] Enable billing for the project
- [ ] Install Google Cloud SDK: `gcloud auth login`
- [ ] Set default project: `gcloud config set project YOUR_PROJECT_ID`

### 2. Enable Required APIs
Run these commands in your terminal:
```bash
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable iamcredentials.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```

### 3. Install Terraform
- Download from: https://www.terraform.io/downloads
- Or use package manager: `brew install terraform` (Mac) or `choco install terraform` (Windows)

## Configuration Steps

### Step 1: Get Your Project Information
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project from the dropdown
3. Note your **Project ID** (not the project name)

### Step 2: Generate SSH Key (if needed)
```bash
# Generate new SSH key
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# View your public key (copy this content)
cat ~/.ssh/id_rsa.pub
```

### Step 3: Update Configuration File
Edit `environments/dev/terraform.tfvars`:

```hcl
# REQUIRED CHANGES:
project_id = "your-actual-project-id"        # ← From Google Cloud Console
ssh_public_key = "ssh-rsa AAAAB3NzaC1..."    # ← Your SSH public key content

# OPTIONAL CHANGES:
region = "us-central1"                       # ← Change if you prefer different region
zone = "us-central1-a"                       # ← Change to match your region
team = "your-team-name"                      # ← Your team name
cost_center = "your-cost-center"             # ← Your cost center
github_repository = "owner/repo"             # ← Only if using GitHub Actions
```

### Step 4: Deploy Infrastructure
```bash
# Initialize Terraform
make init

# Plan the deployment (review what will be created)
make dev-plan

# Apply the changes (create the infrastructure)
make dev-apply
```

### Step 5: Connect to Your VM
After deployment, get the SSH command:
```bash
make output ENV=dev
```

## What Gets Created

✅ **VPC Network**: Isolated network for your resources
✅ **Subnet**: Private subnet with internet access via NAT
✅ **VM Instance**: Ubuntu server with Docker pre-installed
✅ **Firewall Rules**: SSH and HTTP access
✅ **Service Account**: For VM with minimal permissions
✅ **Workload Identity**: For secure CI/CD integration

## Troubleshooting

### Common Issues:

1. **"Project not found"**
   - Verify project ID is correct
   - Ensure you have access to the project

2. **"API not enabled"**
   - Run the API enable commands above

3. **"Insufficient permissions"**
   - Ensure you have Editor or Owner role on the project

4. **"SSH key format error"**
   - Ensure you copied the entire public key content
   - Key should start with `ssh-rsa` or `ssh-ed25519`

### Getting Help:
```bash
# Check Terraform version
terraform version

# Validate configuration
make validate

# Format code
make format
```

## Security Notes

- VM uses Shielded VM features (Secure Boot, vTPM)
- OS Login is enabled for centralized SSH management
- Service account has minimal required permissions
- Firewall rules restrict access to necessary ports only
- Workload Identity eliminates need for service account keys

## Next Steps

After successful deployment:
1. Connect to your VM using the provided SSH command
2. Install additional software as needed
3. Configure your applications
4. Set up monitoring and logging
5. Consider setting up remote state backend for team collaboration