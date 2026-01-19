# 🔑 Phase 2: Service Account Keys - The Traditional Approach

**Duration**: 45 minutes  
**Difficulty**: ⭐⭐ Intermediate  
**Security Level**: ⚠️ High Risk (Educational purposes only)

## 🎯 Learning Objectives

By the end of this phase, you'll understand:
- How service account keys work
- Security risks and why they're discouraged
- When they might still be necessary
- Proper key management practices
- How to migrate away from keys

## ⚠️ Important Security Warning

**Service Account Keys are considered a security anti-pattern in modern GCP deployments.**

We're learning this method to:
- Understand legacy systems
- Recognize security risks
- Know how to migrate away from keys
- Handle situations where keys are unavoidable

## 🏗️ What We'll Build

We'll create a dedicated service account for Terraform operations and use key-based authentication, then analyze the security implications.

## 🛠️ Step 1: Create Terraform Service Account

First, let's create a dedicated service account for Terraform operations:

```bash
# 1. Create service account
gcloud iam service-accounts create terraform-sa \
    --display-name="Terraform Service Account" \
    --description="Service account for Terraform operations" \
    --project=praxis-gear-483220-k4

# 2. Grant necessary permissions
gcloud projects add-iam-policy-binding praxis-gear-483220-k4 \
    --member="serviceAccount:terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding praxis-gear-483220-k4 \
    --member="serviceAccount:terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding praxis-gear-483220-k4 \
    --member="serviceAccount:terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" \
    --role="roles/resourcemanager.projectIamAdmin"

# 3. Verify service account creation
gcloud iam service-accounts list --project=praxis-gear-483220-k4
```

## 🔑 Step 2: Generate and Download Service Account Key

**⚠️ CRITICAL**: Never do this in production!

```bash
# 1. Create keys directory (excluded from git)
mkdir -p labs/phase-2-service-account-keys/keys
echo "keys/" >> .gitignore

# 2. Generate key file
gcloud iam service-accounts keys create \
    labs/phase-2-service-account-keys/keys/terraform-sa-key.json \
    --iam-account=terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com \
    --project=praxis-gear-483220-k4

# 3. Verify key file
Get-Content labs/phase-2-service-account-keys/keys/terraform-sa-key.json | ConvertFrom-Json | Select-Object type, project_id, client_email
```

**Expected Output**:
```json
{
  "type": "service_account",
  "project_id": "praxis-gear-483220-k4",
  "client_email": "terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com"
}
```

## 🔧 Step 3: Configure Terraform to Use Service Account Key

### Method 1: Environment Variable (Recommended for keys)

```bash
# Set environment variable
$env:GOOGLE_APPLICATION_CREDENTIALS = "labs/phase-2-service-account-keys/keys/terraform-sa-key.json"

# Verify environment variable
echo $env:GOOGLE_APPLICATION_CREDENTIALS

# Test authentication
gcloud auth activate-service-account --key-file=$env:GOOGLE_APPLICATION_CREDENTIALS
```

### Method 2: Provider Configuration (Alternative)

Create a new provider configuration:

```hcl
# Save as: labs/phase-2-service-account-keys/provider-with-key.tf

provider "google" {
  credentials = file("labs/phase-2-service-account-keys/keys/terraform-sa-key.json")
  project     = var.project_id
  region      = var.region
}
```

## 🧪 Step 4: Test Key-Based Authentication

```bash
# 1. Clear ADC to force key usage
gcloud auth application-default revoke

# 2. Test Terraform with service account key
terraform plan -var-file="environments/dev/terraform.tfvars"

# 3. Check what identity Terraform is using
terraform console -var-file="environments/dev/terraform.tfvars"
# In console, run: data.google_client_config.current.access_token
```

## 🔍 Step 5: Security Analysis Exercise

Let's analyze the security risks of what we just did:

### **Risk Assessment Checklist**

Create this analysis file:

```bash
# Save as: labs/phase-2-service-account-keys/security-analysis.md
```

```markdown
# Service Account Key Security Analysis

## ✅ What We Did Right
- [ ] Created dedicated service account (not using personal account)
- [ ] Used principle of least privilege (specific roles only)
- [ ] Excluded keys from version control (.gitignore)
- [ ] Used environment variables (not hardcoded in code)

## ❌ Security Risks Identified

### 1. **Long-lived Credentials**
- **Risk**: Keys never expire automatically
- **Impact**: If compromised, attacker has indefinite access
- **Mitigation**: Manual key rotation required

### 2. **Key Storage on Local Machine**
- **Risk**: Keys stored in plaintext on filesystem
- **Impact**: Anyone with file access can use credentials
- **Mitigation**: Encrypted storage, proper file permissions

### 3. **No Audit Trail**
- **Risk**: Can't distinguish between human and automated access
- **Impact**: Difficult to track who did what
- **Mitigation**: Use impersonation for human access

### 4. **Broad Permissions**
- **Risk**: Service account has admin-level permissions
- **Impact**: If compromised, full project access
- **Mitigation**: Narrow permissions, separate accounts per function

### 5. **Key Distribution Problem**
- **Risk**: How to securely share keys with team/CI systems?
- **Impact**: Keys often shared insecurely (email, Slack, etc.)
- **Mitigation**: Use Workload Identity Federation
```

## 🚨 Common Security Mistakes (Don't Do These!)

### **Mistake 1: Committing Keys to Git**

```bash
# Simulate the mistake (DON'T actually commit!)
git add labs/phase-2-service-account-keys/keys/terraform-sa-key.json
git status

# Show why this is dangerous
echo "If you commit this, the key is:"
echo "1. Visible to anyone with repo access"
echo "2. Stored forever in git history"
echo "3. Potentially exposed if repo becomes public"

# Undo the mistake
git reset HEAD labs/phase-2-service-account-keys/keys/terraform-sa-key.json
```

### **Mistake 2: Hardcoding Keys in Code**

```hcl
# BAD - Never do this!
provider "google" {
  credentials = <<EOF
{
  "type": "service_account",
  "project_id": "praxis-gear-483220-k4",
  "private_key": "-----BEGIN PRIVATE KEY-----\n..."
}
EOF
}
```

### **Mistake 3: Overly Broad Permissions**

```bash
# BAD - Never do this!
gcloud projects add-iam-policy-binding praxis-gear-483220-k4 \
    --member="serviceAccount:terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" \
    --role="roles/owner"  # TOO BROAD!
```

## 🛡️ Key Management Best Practices

### **Practice 1: Key Rotation**

```bash
# 1. List existing keys
gcloud iam service-accounts keys list \
    --iam-account=terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com

# 2. Create new key
gcloud iam service-accounts keys create \
    labs/phase-2-service-account-keys/keys/terraform-sa-key-new.json \
    --iam-account=terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com

# 3. Test new key
$env:GOOGLE_APPLICATION_CREDENTIALS = "labs/phase-2-service-account-keys/keys/terraform-sa-key-new.json"
terraform plan -var-file="environments/dev/terraform.tfvars"

# 4. Delete old key (get key ID from step 1)
# gcloud iam service-accounts keys delete KEY_ID \
#     --iam-account=terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com
```

### **Practice 2: Monitoring Key Usage**

```bash
# Check service account activity
gcloud logging read "protoPayload.authenticationInfo.principalEmail=terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" \
    --limit=10 \
    --format="table(timestamp,protoPayload.methodName,protoPayload.resourceName)"
```

### **Practice 3: Least Privilege Principle**

```bash
# Instead of broad roles, use specific permissions
gcloud projects add-iam-policy-binding praxis-gear-483220-k4 \
    --member="serviceAccount:terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" \
    --role="roles/compute.instanceAdmin"  # More specific

# Remove overly broad permissions
gcloud projects remove-iam-policy-binding praxis-gear-483220-k4 \
    --member="serviceAccount:terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" \
    --role="roles/compute.admin"
```

## 🎯 Real-World Scenarios Where Keys Are Still Used

### **Scenario 1: Legacy CI/CD Systems**

**Problem**: Old Jenkins server that doesn't support modern auth

**Solution**:
```bash
# Temporary approach while migrating
# 1. Create dedicated CI service account
# 2. Minimal permissions
# 3. Regular key rotation
# 4. Plan migration to Workload Identity
```

### **Scenario 2: Third-Party Tools**

**Problem**: External monitoring tool needs GCP access

**Solution**:
```bash
# 1. Separate service account per tool
# 2. Read-only permissions where possible
# 3. Regular access reviews
# 4. Monitor usage patterns
```

### **Scenario 3: Emergency Access**

**Problem**: Need break-glass access when other auth methods fail

**Solution**:
```bash
# 1. Emergency service account with broad permissions
# 2. Keys stored in secure vault (not local machines)
# 3. Automatic expiration
# 4. Immediate audit alerts
```

## 🧪 Hands-On Exercise: Key Compromise Simulation

Let's simulate what happens when a key is compromised:

```bash
# 1. Create a "compromised" key scenario
echo "Simulating key compromise..."

# 2. Check current permissions
gcloud projects get-iam-policy praxis-gear-483220-k4 \
    --flatten="bindings[].members" \
    --filter="bindings.members:terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com" \
    --format="table(bindings.role)"

# 3. Immediate response actions
echo "Compromise detected! Taking action..."

# 4. Disable service account
gcloud iam service-accounts disable terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com

# 5. Delete all keys
gcloud iam service-accounts keys list \
    --iam-account=terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com \
    --format="value(name)" | ForEach-Object {
    $keyId = ($_ -split "/")[-1]
    gcloud iam service-accounts keys delete $keyId \
        --iam-account=terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com \
        --quiet
}

# 6. Verify key deletion
gcloud iam service-accounts keys list \
    --iam-account=terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com
```

## 📊 Comparison: Keys vs Modern Methods

| Aspect | Service Account Keys | Impersonation | Workload Identity |
|--------|---------------------|---------------|-------------------|
| **Setup Time** | 5 minutes | 15 minutes | 30 minutes |
| **Security** | ⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Key Management** | Manual | None | None |
| **Audit Trail** | Limited | Full | Full |
| **Expiration** | Never | 1 hour | 1 hour |
| **Compromise Risk** | High | Low | Very Low |

## 🎓 Technical Questions & Answers

**Q: Why are service account keys considered a security anti-pattern?**

**A**: Service account keys are long-lived credentials that never expire automatically, creating several risks: 1) If compromised, attackers have indefinite access, 2) Keys are stored as files that can be accidentally shared or committed to version control, 3) No automatic rotation means manual key management, 4) Difficult to audit who's using the key, 5) Keys often get overly broad permissions for convenience.

**Q: When might you still need to use service account keys?**

**A**: Limited scenarios include: 1) Legacy systems that don't support modern authentication, 2) Third-party tools without Workload Identity support, 3) Emergency break-glass access procedures, 4) Temporary migration scenarios. In all cases, they should be treated as technical debt with plans to migrate to better methods.

**Q: How would you secure service account keys if you must use them?**

**A**: Best practices include: 1) Principle of least privilege - minimal required permissions, 2) Regular key rotation (monthly or quarterly), 3) Secure storage (encrypted, not in version control), 4) Monitoring and alerting on key usage, 5) Separate service accounts per function, 6) Automatic key expiration where possible, 7) Regular access reviews.

## 🧹 Cleanup

Before moving to Phase 3, let's clean up:

```bash
# 1. Restore ADC authentication
gcloud auth application-default login

# 2. Clear environment variable
$env:GOOGLE_APPLICATION_CREDENTIALS = ""

# 3. Disable the service account (keep for learning)
gcloud iam service-accounts disable terraform-sa@praxis-gear-483220-k4.iam.gserviceaccount.com

# 4. Verify cleanup
terraform plan -var-file="environments/dev/terraform.tfvars"
```

## ✅ Phase 2 Completion Checklist

- [ ] Created service account and generated keys
- [ ] Successfully used key-based authentication
- [ ] Completed security analysis exercise
- [ ] Simulated key compromise scenario
- [ ] Understand when keys are/aren't appropriate
- [ ] Can explain security risks in technical context

## 🚀 Next Steps

**Key Takeaways**:
- Service account keys work but are high-risk
- Modern alternatives are almost always better
- If you must use keys, follow strict security practices
- Plan migration away from keys

**Ready for Phase 3?**  
Now let's learn Service Account Impersonation - a much more secure approach that eliminates key management entirely.

**Continue to**: [Phase 3 - Service Account Impersonation](../phase-3-impersonation/README.md)

---

**🎉 Phase 2 Complete!** You now understand the traditional approach and why modern enterprises are moving away from service account keys.