# 🎯 TERRAFORM INTERVIEW PREPARATION - PART 4: SCENARIO-BASED QUESTIONS

## 🎭 REAL-WORLD SCENARIOS

### **SCENARIO 1: "A team member accidentally deleted the VPC in GCP console. What do you do?"**

**Answer**:
"This is a common disaster recovery scenario. Here's my approach:

**Step 1: Assess the Damage**
```bash
terraform refresh  # Updates state with actual GCP state
terraform plan     # Shows what's missing
```

**Step 2: Understand the Impact**
- VPC deleted → Subnet, VM, firewall rules also affected
- Terraform state still has old VPC ID
- Resources are orphaned

**Step 3: Recovery Options**

**Option A: Recreate Everything** (Recommended)
```bash
# Remove deleted resources from state
terraform state rm google_compute_network.vpc
terraform state rm google_compute_subnetwork.subnet
terraform state rm google_compute_instance.vm

# Recreate
terraform apply
```

**Option B: Import Existing** (If partially exists)
```bash
terraform import google_compute_network.vpc projects/PROJECT/global/networks/dev-vpc
```

**Step 4: Prevention**
- Enable deletion protection:
```hcl
resource "google_compute_network" "vpc" {
  name = "dev-vpc"
  
  lifecycle {
    prevent_destroy = true  # Terraform blocks deletion
  }
}
```
- Use GCP Organization Policies
- Restrict console access
- Use IAM conditions

**Step 5: Post-Incident**
- Document what happened
- Review access controls
- Implement safeguards
- Update runbooks

**Key Point**: Terraform makes recovery easy because infrastructure is code!"

---

### **SCENARIO 2: "You need to add a new VM to production without downtime. How?"**

**Answer**:
"This tests understanding of Terraform's update behavior:

**Step 1: Analyze Current Setup**
```hcl
# Current: Single VM
resource "google_compute_instance" "vm" {
  name = "prod-vm"
  # ...
}
```

**Step 2: Plan the Change**
```hcl
# New: Multiple VMs using count
resource "google_compute_instance" "vm" {
  count = 2  # Add this
  
  name = "prod-vm-${count.index}"
  # ...
}
```

**Step 3: Check Impact**
```bash
terraform plan
```

**Problem**: This will DESTROY existing VM and create 2 new ones!

**Better Approach: Add New Resource**
```hcl
# Keep existing
resource "google_compute_instance" "vm" {
  name = "prod-vm"
}

# Add new
resource "google_compute_instance" "vm_2" {
  name = "prod-vm-2"
}
```

**Step 4: Safe Deployment**
```bash
terraform plan  # Verify only addition
terraform apply -target=google_compute_instance.vm_2  # Create only new VM
```

**Step 5: Load Balancer Update**
```hcl
resource "google_compute_backend_service" "backend" {
  backend {
    group = google_compute_instance.vm.self_link
  }
  backend {
    group = google_compute_instance.vm_2.self_link  # Add new
  }
}
```

**Best Practice: Use Instance Groups**
```hcl
resource "google_compute_instance_group_manager" "group" {
  name               = "prod-group"
  base_instance_name = "prod-vm"
  target_size        = 2  # Just change this number
}
```

**Zero Downtime Achieved**:
- New VM created first
- Added to load balancer
- Traffic gradually shifts
- Old VM can be removed later"

---

### **SCENARIO 3: "State file is corrupted. How do you recover?"**

**Answer**:
"State corruption is serious but recoverable:

**Step 1: Don't Panic - Check Backups**
```bash
# GCS backend keeps versions
gsutil ls gs://my-terraform-state/terraform/state/

# List versions
gsutil ls -a gs://my-terraform-state/terraform/state/default.tfstate
```

**Step 2: Restore from Backup**
```bash
# Download previous version
gsutil cp gs://my-terraform-state/terraform/state/default.tfstate#1234567 terraform.tfstate

# Test it
terraform plan
```

**Step 3: If No Backup - Rebuild State**
```bash
# Remove corrupted state
rm terraform.tfstate

# Import each resource manually
terraform import google_compute_network.vpc projects/PROJECT/global/networks/dev-vpc
terraform import google_compute_subnetwork.subnet projects/PROJECT/regions/us-central1/subnetworks/dev-subnet
terraform import google_compute_instance.vm projects/PROJECT/zones/us-central1-a/instances/dev-vm
```

**Step 4: Verify**
```bash
terraform plan  # Should show no changes
```

**Prevention**:
1. **Remote Backend with Versioning**:
```hcl
terraform {
  backend "gcs" {
    bucket  = "my-state"
    prefix  = "terraform/state"
    # GCS automatically versions
  }
}
```

2. **State Locking**:
- Prevents concurrent modifications
- GCS provides automatic locking

3. **Regular Backups**:
```bash
# Automated backup script
terraform state pull > backup-$(date +%Y%m%d).tfstate
```

4. **Access Control**:
- Limit who can modify state
- Use IAM conditions
- Audit state access

**Recovery Time**: 
- With backup: 5 minutes
- Without backup: 1-2 hours (depending on resource count)"

---

### **SCENARIO 4: "How do you migrate from one GCP project to another?"**

**Answer**:
"Project migration requires careful planning:

**Approach 1: Recreate in New Project** (Recommended)

**Step 1: Prepare New Project**
```hcl
# Update terraform.tfvars
project_id = "new-project-id"  # Change this
```

**Step 2: Create New State**
```bash
# Use different state file
terraform init -backend-config="prefix=new-project/state"
```

**Step 3: Deploy to New Project**
```bash
terraform apply
```

**Step 4: Migrate Data**
- Export data from old project
- Import to new project
- Update DNS/load balancers
- Test thoroughly

**Step 5: Decommission Old**
```bash
# Switch to old state
terraform init -backend-config="prefix=old-project/state"

# Destroy old resources
terraform destroy
```

**Approach 2: Move Resources** (Complex)

**Step 1: Export Resources**
```bash
# In old project
terraform state pull > old-state.json
```

**Step 2: Modify State**
```bash
# Change project IDs in state file
# Very risky - not recommended
```

**Step 3: Import to New**
```bash
# Import each resource to new project
terraform import google_compute_network.vpc projects/NEW_PROJECT/...
```

**Challenges**:
- Some resources can't be moved (VPCs, subnets)
- Downtime required
- DNS propagation delays
- Data migration complexity

**Best Practice**:
- Use blue-green deployment
- Run both projects temporarily
- Gradual traffic migration
- Rollback plan ready

**Timeline**:
- Planning: 1 week
- Execution: 1 day
- Validation: 1 week
- Decommission: After validation"

---

### **SCENARIO 5: "Terraform plan shows unexpected changes. How do you debug?"**

**Answer**:
"Unexpected changes indicate drift or configuration issues:

**Step 1: Identify the Drift**
```bash
terraform plan -out=plan.out
terraform show plan.out  # Detailed view
```

**Step 2: Common Causes**

**Cause 1: Manual Changes in Console**
```
Plan shows: Update VM machine_type
Reason: Someone changed it in console
Solution: Either accept change or revert in console
```

**Cause 2: Provider Version Change**
```
Plan shows: Update all resources
Reason: Provider updated, new defaults
Solution: Pin provider version
```

**Cause 3: Variable Value Changed**
```
Plan shows: Recreate VM
Reason: terraform.tfvars was modified
Solution: Review git diff on tfvars
```

**Step 3: Investigation Commands**
```bash
# Compare state with reality
terraform refresh

# Show current state
terraform state show google_compute_instance.vm

# Show what changed
terraform plan -detailed-exitcode

# Check specific resource
terraform state pull | jq '.resources[] | select(.name=="vm")'
```

**Step 4: Debugging Techniques**

**Check Git History**:
```bash
git diff HEAD~1 main.tf
git log --oneline terraform.tfvars
```

**Check GCP Audit Logs**:
- Who made manual changes?
- When were they made?
- What was changed?

**Compare Configurations**:
```bash
# What Terraform thinks
terraform state show google_compute_instance.vm

# What GCP has
gcloud compute instances describe dev-vm
```

**Step 5: Resolution**

**Option A: Accept Drift**
```bash
terraform apply  # Updates to match code
```

**Option B: Update Code**
```hcl
# Match current GCP state
resource "google_compute_instance" "vm" {
  machine_type = "e2-standard-2"  # Update to current
}
```

**Option C: Ignore Changes**
```hcl
resource "google_compute_instance" "vm" {
  machine_type = var.machine_type
  
  lifecycle {
    ignore_changes = [machine_type]  # Ignore this field
  }
}
```

**Prevention**:
- Disable console access for managed resources
- Use Organization Policies
- Regular drift detection
- Automated terraform plan in CI/CD
- Alert on manual changes"

---

### **SCENARIO 6: "You need to rename a resource without recreating it"**

**Answer**:
"Renaming in Terraform requires state manipulation:

**Problem**:
```hcl
# Old
resource "google_compute_instance" "vm" {
  name = "old-vm"
}

# Want to rename to
resource "google_compute_instance" "web_server" {
  name = "old-vm"  # Keep GCP name same
}
```

**If you just change code**:
```bash
terraform plan
# Shows: Destroy vm, Create web_server
# This recreates the VM! ❌
```

**Solution: State Move**
```bash
# Move in state without touching GCP
terraform state mv google_compute_instance.vm google_compute_instance.web_server

# Now update code
# Change resource name in .tf files

terraform plan
# Shows: No changes ✓
```

**Complete Example**:

**Step 1: Current State**
```hcl
resource "google_compute_instance" "vm" {
  name = "prod-vm"
}
```

**Step 2: Move in State**
```bash
terraform state mv \
  google_compute_instance.vm \
  google_compute_instance.production_server
```

**Step 3: Update Code**
```hcl
resource "google_compute_instance" "production_server" {
  name = "prod-vm"  # GCP name unchanged
}
```

**Step 4: Update References**
```hcl
# Update any references
output "vm_ip" {
  value = google_compute_instance.production_server.network_interface[0].access_config[0].nat_ip
}
```

**Step 5: Verify**
```bash
terraform plan  # Should show no changes
```

**Advanced: Rename GCP Resource Too**
```hcl
resource "google_compute_instance" "production_server" {
  name = "production-server"  # New GCP name
}
```
This WILL recreate - no way around it for VMs.

**Alternative: Use Moved Block** (Terraform 1.1+)
```hcl
moved {
  from = google_compute_instance.vm
  to   = google_compute_instance.production_server
}

resource "google_compute_instance" "production_server" {
  name = "prod-vm"
}
```
Terraform handles the state move automatically!"

---

