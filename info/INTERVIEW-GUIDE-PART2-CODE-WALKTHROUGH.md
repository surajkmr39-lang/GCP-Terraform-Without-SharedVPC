# 🎯 TERRAFORM INTERVIEW PREPARATION - PART 2: CODE WALKTHROUGH

## 📝 NETWORK MODULE DEEP DIVE

### **File: modules/network/main.tf**

```hcl
resource "google_compute_network" "vpc" {
  name                    = "${var.environment}-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}
```

**Interview Question**: "Explain this VPC resource"

**Answer**: 
"This creates a Google Cloud VPC network. Let me break it down:

- `google_compute_network` - The resource type from Google provider
- `vpc` - Local name I can reference as `google_compute_network.vpc`
- `name = "${var.environment}-vpc"` - String interpolation, creates 'dev-vpc' for dev environment
- `auto_create_subnetworks = false` - I want manual control over subnets for security
- `project = var.project_id` - Specifies which GCP project

**Why manual subnets?**
- Better security control
- Custom IP ranges
- Specific regional placement
- Follows enterprise best practices"

---

```hcl
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.environment}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  
  private_ip_google_access = true
  
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
```

**Interview Question**: "What's happening in the subnet configuration?"

**Answer**:
"This creates a subnet within the VPC:

- `network = google_compute_network.vpc.id` - **IMPLICIT DEPENDENCY**: Terraform knows to create VPC first
- `ip_cidr_range = var.subnet_cidr` - IP range (10.0.1.0/24 = 256 IPs)
- `private_ip_google_access = true` - VMs can reach Google APIs without external IP
- `log_config` - Enables VPC Flow Logs for security monitoring

**Flow Logs Benefits**:
- Network troubleshooting
- Security analysis
- Cost optimization
- Compliance requirements

I configured 10-minute intervals with 50% sampling to balance cost and visibility."

---

```hcl
resource "google_compute_router" "router" {
  name    = "${var.environment}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.environment}-nat"
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
```

**Interview Question**: "Why do you need Cloud NAT?"

**Answer**:
"Cloud NAT provides secure outbound internet access for private VMs:

**Without NAT**:
- VMs need external IPs (security risk)
- More attack surface
- Higher costs

**With NAT**:
- VMs stay private (no external IP)
- Outbound internet access for updates
- Centralized egress point
- Better security posture

**Configuration**:
- `AUTO_ONLY` - Google manages IP allocation
- `ALL_SUBNETWORKS_ALL_IP_RANGES` - All VMs can use NAT
- Router acts as gateway

**Real-world use**: VMs can download packages, call APIs, but can't be directly accessed from internet."

---

## 📝 IAM MODULE DEEP DIVE

### **File: modules/iam/main.tf**

```hcl
resource "google_service_account" "vm_service_account" {
  account_id   = "${var.environment}-vm-sa"
  display_name = "Service Account for ${var.environment} VM"
  project      = var.project_id
}
```

**Interview Question**: "What is a service account and why use it?"

**Answer**:
"A service account is a special Google account for applications, not humans.

**Why use it?**
- VMs need identity to access GCP services
- Follows principle of least privilege
- No user credentials on VMs
- Auditable access

**In my project**:
- Each VM uses this service account
- Granted only necessary permissions (compute viewer, storage, logging)
- Can be rotated without touching VMs"

---

```hcl
resource "google_project_iam_member" "vm_sa_compute_viewer" {
  project = var.project_id
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}
```

**Interview Question**: "Explain IAM binding vs member vs policy"

**Answer**:
"Three ways to grant permissions in GCP:

**1. google_project_iam_member** (What I used):
- Adds ONE member to ONE role
- Non-authoritative (doesn't remove other members)
- Safe for shared projects
- Example: Add service account to compute.viewer

**2. google_project_iam_binding**:
- Manages ALL members for ONE role
- Authoritative (replaces all members)
- Risky - can remove others' access
- Use when you own the entire role

**3. google_project_iam_policy**:
- Manages ALL roles and members
- Most authoritative
- Very risky - can lock yourself out
- Rarely used

**I chose iam_member** because:
- Safe in shared projects
- Won't conflict with other Terraform code
- Clear and explicit"

---

```hcl
resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = "${var.environment}-pool"
  display_name              = "${var.environment} Workload Identity Pool"
  project                   = var.project_id
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  
  attribute_condition = "assertion.repository == '${var.github_repository}'"
  
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}
```

**Interview Question**: "Explain Workload Identity Federation and why it's important"

**Answer**:
"WIF is Google's keyless authentication for external workloads.

**Traditional Approach** (BAD):
```
GitHub Actions → Uses Service Account Key (JSON file)
                 ↓
              Security Risks:
              - Keys can leak
              - Keys don't expire
              - Hard to rotate
              - Stored in GitHub secrets
```

**Workload Identity Federation** (GOOD):
```
GitHub Actions → Requests OIDC token from GitHub
                 ↓
              Google validates token
                 ↓
              Issues temporary token (1 hour)
                 ↓
              No keys stored anywhere!
```

**My Implementation**:
1. **Pool**: Container for identity providers
2. **Provider**: Trusts GitHub's OIDC tokens
3. **Attribute Mapping**: Maps GitHub claims to Google attributes
4. **Condition**: Only my repository can authenticate
5. **Binding**: Allows GitHub to impersonate service account

**Benefits**:
- Zero stored credentials
- Automatic token rotation
- Repository-specific access
- Audit trail
- Follows security best practices

**Real Interview Tip**: This is a HOT topic - many companies are migrating to WIF!"

---

## 📝 SECURITY MODULE DEEP DIVE

### **File: modules/security/main.tf**

```hcl
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.environment}-allow-ssh"
  network = var.network_name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = var.ssh_source_ranges
  target_tags   = ["ssh-allowed"]
}
```

**Interview Question**: "How do firewall rules work in GCP?"

**Answer**:
"GCP firewalls are stateful and applied at VPC level:

**Key Concepts**:
- `source_ranges` - Which IPs can connect (0.0.0.0/0 = anywhere)
- `target_tags` - Which VMs this applies to
- `allow` block - What traffic is permitted

**Tag-based targeting**:
- VMs with tag 'ssh-allowed' get SSH access
- Other VMs in same VPC don't
- Granular control without complex rules

**Stateful**:
- Allow inbound SSH → Response automatically allowed
- Don't need separate outbound rule

**Security Best Practice**:
- Use specific source_ranges (not 0.0.0.0/0 in production)
- Use tags for flexibility
- Separate rules for different services
- Enable logging for audit"

---

