# 🔐 Workload Identity Federation - Quick Reference

## 🎯 **What is Workload Identity Federation (WIF)?**

WIF allows external workloads (like GitHub Actions) to authenticate to Google Cloud without storing service account keys. It uses OIDC tokens for secure, keyless authentication.

## 🏗️ **Our WIF Setup**

### **Components:**
- **Workload Identity Pool**: `github-pool`
- **Provider**: GitHub Actions OIDC
- **Service Account**: `galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com`
- **Repository**: `surajkmr39-lang/GCP-Terraform`

### **Configuration:**
```hcl
# Workload Identity Pool
resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Identity pool for GitHub Actions"
}

# GitHub Provider
resource "google_iam_workload_identity_pool_provider" "provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub Actions Provider"
  
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
```

## 🔑 **Authentication Flow**

### **Step-by-Step Process:**
1. **GitHub Action Starts** → Workflow triggered
2. **OIDC Token Request** → GitHub generates OIDC token
3. **Token Exchange** → Token sent to Google Cloud STS
4. **Identity Verification** → Google validates token against WIF pool
5. **Service Account Impersonation** → Temporary credentials issued
6. **Resource Access** → Terraform operations with temporary credentials

### **GitHub Actions Workflow:**
```yaml
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v1
  with:
    workload_identity_provider: projects/123456789/locations/global/workloadIdentityPools/github-pool/providers/github
    service_account: galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com
```

## 🛡️ **Security Benefits**

### **Why WIF is Superior:**
- ✅ **No Stored Keys**: Zero service account keys in repositories
- ✅ **Short-lived Tokens**: Temporary credentials with automatic expiration
- ✅ **Attribute-based Access**: Fine-grained control based on repository/branch
- ✅ **Audit Trail**: Complete logging of authentication events
- ✅ **Automatic Rotation**: No manual key rotation required

### **Traditional vs WIF:**
| Aspect | Service Account Keys | Workload Identity Federation |
|--------|---------------------|------------------------------|
| **Storage** | Stored in GitHub Secrets | No keys stored |
| **Rotation** | Manual rotation required | Automatic |
| **Scope** | Broad permissions | Attribute-based restrictions |
| **Audit** | Limited visibility | Complete audit trail |
| **Security Risk** | High (key compromise) | Low (temporary tokens) |

## 🔍 **Validation Commands**

### **Check WIF Status:**
```powershell
# Run our validation script
./Check-WIF-Status.ps1
```

### **Manual Verification:**
```bash
# List workload identity pools
gcloud iam workload-identity-pools list --location=global

# Describe specific pool
gcloud iam workload-identity-pools describe github-pool --location=global

# List providers
gcloud iam workload-identity-pools providers list --workload-identity-pool=github-pool --location=global

# Check service account IAM bindings
gcloud iam service-accounts get-iam-policy galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com
```

## 🎯 **Interview Questions & Answers**

### **Q: "What is Workload Identity Federation and why use it?"**
**A:** "WIF is Google Cloud's keyless authentication mechanism that allows external workloads like GitHub Actions to authenticate without storing service account keys. It uses OIDC tokens for secure, temporary access. I use it because it eliminates the security risk of stored keys, provides automatic token rotation, and enables fine-grained access control based on repository attributes."

### **Q: "How does WIF improve security compared to service account keys?"**
**A:** "WIF eliminates the biggest security risk - stored credentials. Instead of long-lived keys that could be compromised, it uses short-lived OIDC tokens. There's no key rotation burden, complete audit trails, and I can restrict access based on specific repositories or branches. If someone gains access to the workflow, they can't extract permanent credentials."

### **Q: "Walk me through the WIF authentication flow."**
**A:** "When a GitHub Action runs, GitHub generates an OIDC token containing claims about the workflow context. This token is sent to Google Cloud's Security Token Service, which validates it against our WIF pool configuration. If valid, Google issues temporary credentials for our service account. The workflow then uses these temporary credentials for Terraform operations. The entire process is keyless and automatic."

### **Q: "How do you configure attribute-based access control with WIF?"**
**A:** "I configure attribute mapping in the WIF provider to extract claims from the OIDC token - like repository name, branch, and actor. Then I can create IAM conditions that restrict access based on these attributes. For example, only allowing access from our specific repository or only from the main branch for production deployments."

## 🔧 **Troubleshooting**

### **Common Issues:**

**1. Authentication Failures:**
```bash
# Check if WIF pool exists
gcloud iam workload-identity-pools describe github-pool --location=global

# Verify provider configuration
gcloud iam workload-identity-pools providers describe github --workload-identity-pool=github-pool --location=global
```

**2. Permission Denied:**
```bash
# Check service account IAM bindings
gcloud iam service-accounts get-iam-policy galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com

# Verify workloadIdentityUser binding
gcloud projects get-iam-policy praxis-gear-483220-k4 --flatten="bindings[].members" --filter="bindings.role:roles/iam.workloadIdentityUser"
```

**3. Token Exchange Errors:**
```bash
# Check OIDC configuration
curl -s https://token.actions.githubusercontent.com/.well-known/openid_configuration

# Verify issuer URI matches
gcloud iam workload-identity-pools providers describe github --workload-identity-pool=github-pool --location=global --format="value(oidc.issuerUri)"
```

## 📊 **Monitoring & Auditing**

### **Audit Logs:**
```bash
# View WIF authentication events
gcloud logging read "resource.type=iam_workload_identity_pool" --limit=10

# Check service account usage
gcloud logging read "protoPayload.authenticationInfo.principalEmail=galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com" --limit=10
```

### **Metrics to Monitor:**
- Authentication success/failure rates
- Token exchange frequency
- Service account impersonation events
- Failed access attempts

## 🚀 **Best Practices**

### **Configuration:**
1. **Use descriptive names** for pools and providers
2. **Implement attribute-based restrictions** for fine-grained access
3. **Regular audit** of WIF configurations and bindings
4. **Monitor authentication events** for security

### **Security:**
1. **Principle of least privilege** for service account permissions
2. **Environment-specific service accounts** when possible
3. **Regular review** of IAM bindings and access patterns
4. **Implement conditional access** based on repository/branch

### **Operations:**
1. **Document WIF setup** for team knowledge sharing
2. **Test authentication** in CI/CD pipelines regularly
3. **Have rollback plan** for WIF configuration changes
4. **Monitor for deprecated features** and update accordingly

## 🎪 **Demo Script**

### **Live Demonstration:**
```bash
# 1. Show WIF configuration
gcloud iam workload-identity-pools describe github-pool --location=global

# 2. Display provider details
gcloud iam workload-identity-pools providers describe github --workload-identity-pool=github-pool --location=global

# 3. Check service account bindings
gcloud iam service-accounts get-iam-policy galaxy@praxis-gear-483220-k4.iam.gserviceaccount.com

# 4. Run validation script
./Check-WIF-Status.ps1

# 5. Show GitHub Actions workflow using WIF
cat .github/workflows/cicd-pipeline.yml
```

**Talking Points:**
- "This shows our keyless authentication setup"
- "Notice there are no stored credentials anywhere"
- "The service account has minimal required permissions"
- "Authentication is automatic and secure"

This WIF setup demonstrates enterprise-grade security practices and modern cloud authentication patterns! 🔐