# 🔐 Phase 1: Application Default Credentials (ADC) Deep Dive

**Duration**: 30 minutes  
**Difficulty**: ⭐ Beginner  
**Status**: ✅ Currently implemented in your project

## 🎯 Learning Objectives

By the end of this phase, you'll understand:
- How ADC works under the hood
- Where credentials are stored
- Credential precedence order
- Troubleshooting ADC issues
- When to use ADC vs other methods

## 📋 Current State Analysis

Your project is already using ADC! Let's understand what's happening.

### 🔍 Step 1: Examine Your Current Setup

<function_calls>
<invoke name="executePwsh">
<parameter name="command">gcloud auth list
```bash
# Check your current authentication
gcloud auth list

# Check application default credentials
gcloud auth application-default print-access-token

# Check which project is active
gcloud config get-value project
```

**Expected Output**:
```
ACTIVE: *
ACCOUNT: rksuraj@learningmyway.space

Project: praxis-gear-483220-k4
```

### 🔍 Step 2: Understand ADC File Location

```bash
# Windows location
echo $env:APPDATA\gcloud\application_default_credentials.json

# Check if file exists
Test-Path "$env:APPDATA\gcloud\application_default_credentials.json"
```

### 🔍 Step 3: Examine Terraform Provider Configuration

Look at your `main.tf`:

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
  # No explicit credentials - uses ADC automatically!
}
```

**Key Point**: When no credentials are specified, Terraform automatically uses ADC.

## 🧠 How ADC Works - Deep Dive

### 📊 Credential Search Order

Google Cloud libraries search for credentials in this order:

1. **GOOGLE_APPLICATION_CREDENTIALS** environment variable
2. **gcloud ADC** (`gcloud auth application-default login`)
3. **Compute Engine metadata** (when running on GCP)
4. **Error** if none found

### 🏗️ ADC Architecture

```
Your Terraform → Google Auth Library → Credential Search → GCP APIs
                                    ↓
                            1. Check env vars
                            2. Check ADC file
                            3. Check metadata server
                            4. Fail with error
```

## 🛠️ Hands-On Exercises

### **Exercise 1: ADC Credential Inspection**

```bash
# 1. Check current ADC status
gcloud auth application-default print-access-token

# 2. Decode the token (first part before first dot)
# Copy the token and decode at https://jwt.io
# Look for: iss, aud, exp, email fields
```

**What to observe**:
- Token expiration time (usually 1 hour)
- Your email in the token
- Issuer: `https://accounts.google.com`

### **Exercise 2: Test Terraform with ADC**

```bash
# 1. Navigate to your project root
cd C:\GCP-Terraform-7th-Jan-2026

# 2. Test Terraform plan (should work with ADC)
terraform plan -var-file="environments/dev/terraform.tfvars"

# 3. Check what credentials Terraform is using
$env:TF_LOG="DEBUG"
terraform plan -var-file="environments/dev/terraform.tfvars" 2>&1 | Select-String "auth"
```

### **Exercise 3: ADC Refresh Simulation**

```bash
# 1. Check current token expiry
gcloud auth application-default print-access-token | ForEach-Object {
    $token = $_
    # Token will expire in ~1 hour
    Write-Host "Token obtained at: $(Get-Date)"
}

# 2. Force refresh ADC
gcloud auth application-default login --force

# 3. Verify new token
gcloud auth application-default print-access-token
```

## 🚨 Common Issues & Troubleshooting

### **Issue 1: "oauth2: invalid_grant" Error**

**Symptoms**:
```
Error: oauth2: "invalid_grant" "reauth related error (invalid_rapt)"
```

**Solution**:
```bash
# Refresh your ADC
gcloud auth application-default login

# If still failing, revoke and re-authenticate
gcloud auth application-default revoke
gcloud auth application-default login
```

### **Issue 2: Wrong Project Context**

**Symptoms**:
```
Error: googleapi: Error 403: Project 'wrong-project' is not found
```

**Solution**:
```bash
# Check current project
gcloud config get-value project

# Set correct project
gcloud config set project praxis-gear-483220-k4

# Verify
gcloud config list
```

### **Issue 3: Insufficient Permissions**

**Symptoms**:
```
Error: googleapi: Error 403: The caller does not have permission
```

**Solution**:
```bash
# Check your roles
gcloud projects get-iam-policy praxis-gear-483220-k4 \
  --flatten="bindings[].members" \
  --format="table(bindings.role)" \
  --filter="bindings.members:rksuraj@learningmyway.space"
```

## 📊 ADC vs Other Methods Comparison

| Aspect | ADC | Service Account Keys | Impersonation | WIF |
|--------|-----|---------------------|---------------|-----|
| **Setup Complexity** | ⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Security** | ⭐⭐ | ⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Local Development** | ✅ | ✅ | ✅ | ❌ |
| **CI/CD** | ❌ | ⭐ | ⭐ | ✅ |
| **Enterprise Use** | ❌ | ❌ | ✅ | ✅ |

## 🎯 Real-World Scenarios

### **Scenario 1: New Developer Onboarding**

**Problem**: New team member can't run Terraform

**Solution Process**:
```bash
# 1. Install gcloud CLI
# 2. Authenticate
gcloud auth login

# 3. Set up ADC
gcloud auth application-default login

# 4. Set project
gcloud config set project praxis-gear-483220-k4

# 5. Test access
terraform plan -var-file="environments/dev/terraform.tfvars"
```

### **Scenario 2: Multiple GCP Projects**

**Problem**: Working on multiple projects, credentials getting mixed

**Solution**:
```bash
# Use gcloud configurations
gcloud config configurations create project-a
gcloud config configurations create project-b

# Switch between projects
gcloud config configurations activate project-a
gcloud config set project praxis-gear-483220-k4
gcloud auth application-default login

# Verify current context
gcloud config configurations list
```

## 🧪 Verification Tests

Create this test script to verify your ADC setup:

```powershell
# Save as: labs/phase-1-adc/verify-adc.ps1

Write-Host "=== ADC Verification Script ===" -ForegroundColor Green

# Test 1: Check gcloud auth
Write-Host "`n1. Checking gcloud authentication..." -ForegroundColor Yellow
$authList = gcloud auth list --format="value(account,status)"
Write-Host "Active account: $authList"

# Test 2: Check ADC token
Write-Host "`n2. Checking ADC token..." -ForegroundColor Yellow
try {
    $token = gcloud auth application-default print-access-token
    Write-Host "✅ ADC token obtained successfully"
    Write-Host "Token length: $($token.Length) characters"
} catch {
    Write-Host "❌ Failed to get ADC token: $_" -ForegroundColor Red
}

# Test 3: Check project context
Write-Host "`n3. Checking project context..." -ForegroundColor Yellow
$project = gcloud config get-value project
Write-Host "Current project: $project"

if ($project -eq "praxis-gear-483220-k4") {
    Write-Host "✅ Correct project configured"
} else {
    Write-Host "❌ Wrong project. Expected: praxis-gear-483220-k4" -ForegroundColor Red
}

# Test 4: Test Terraform
Write-Host "`n4. Testing Terraform with ADC..." -ForegroundColor Yellow
Set-Location "C:\GCP-Terraform-7th-Jan-2026"
$planResult = terraform plan -var-file="environments/dev/terraform.tfvars" -detailed-exitcode
if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 2) {
    Write-Host "✅ Terraform plan successful with ADC"
} else {
    Write-Host "❌ Terraform plan failed" -ForegroundColor Red
}

Write-Host "`n=== ADC Verification Complete ===" -ForegroundColor Green
```

Run the verification:
```bash
# Make executable and run
PowerShell -ExecutionPolicy Bypass -File labs/phase-1-adc/verify-adc.ps1
```

## 📚 Key Takeaways

### **When to Use ADC**
✅ **Good for**:
- Local development
- Personal projects
- Learning and experimentation
- Quick prototyping

❌ **Not good for**:
- Production CI/CD pipelines
- Shared environments
- Enterprise security requirements
- Automated systems

### **Security Considerations**
- ADC uses your personal Google account
- Tokens expire every hour (auto-refresh)
- Credentials stored locally on your machine
- No fine-grained access control

### **Best Practices**
1. **Regular refresh**: Run `gcloud auth application-default login` daily
2. **Project isolation**: Use gcloud configurations for multiple projects
3. **Credential hygiene**: Never commit ADC files to version control
4. **Monitoring**: Be aware of token expiration times

## 🎓 Technical Questions & Answers

**Q: What is Application Default Credentials and how does it work?**

**A**: ADC is Google Cloud's standard way to provide credentials to applications. It follows a credential search order: environment variables, ADC file from gcloud, compute metadata, then fails. It's designed for local development where you authenticate once with `gcloud auth application-default login` and all Google Cloud libraries automatically use those credentials.

**Q: What are the security implications of using ADC?**

**A**: ADC uses your personal Google account credentials, which may have broader permissions than needed. It's suitable for development but not for production because: 1) It uses personal accounts rather than service accounts, 2) Credentials are stored on local machines, 3) No fine-grained access control, 4) Difficult to audit and rotate.

**Q: How would you troubleshoot ADC authentication issues?**

**A**: First, check `gcloud auth list` to verify authentication. Then check `gcloud config get-value project` for correct project. If getting invalid_grant errors, refresh with `gcloud auth application-default login`. For permission errors, verify IAM roles. Use `TF_LOG=DEBUG` to see what credentials Terraform is using.

## ✅ Phase 1 Completion Checklist

- [ ] Understand how ADC works
- [ ] Successfully run verification script
- [ ] Troubleshoot at least one ADC issue
- [ ] Know when to use vs avoid ADC
- [ ] Can explain ADC in technical context

## 🚀 Next Steps

**Ready for Phase 2?**  
Now that you understand ADC, let's explore Service Account Keys and understand why they're risky but sometimes necessary.

**Continue to**: [Phase 2 - Service Account Keys](../phase-2-service-account-keys/README.md)

---

**🎉 Congratulations!** You've mastered Application Default Credentials. You now understand the foundation of GCP authentication and can troubleshoot common issues.