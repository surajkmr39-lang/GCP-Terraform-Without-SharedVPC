# Terraform State Management Commands

## Overview
Terraform state is a critical component that tracks the mapping between your configuration files and real-world resources. Understanding state commands is essential for managing infrastructure effectively.

## State File Location
- **Current workspace**: `dev` (you're using Terraform workspaces)
- **State file location**: `terraform.tfstate.d/dev/terraform.tfstate`
- **Backup file**: `terraform.tfstate.d/dev/terraform.tfstate.backup`

## Essential State Commands

### 1. `terraform state list`
**Purpose**: Shows all resources currently managed by Terraform
**Usage**: `terraform state list`
**Output**: List of resource addresses in the format `module.name.resource_type.resource_name`

**Your Current Resources (15 total)**:
```
module.compute.google_compute_instance.vm
module.iam.google_iam_workload_identity_pool.pool
module.iam.google_project_iam_member.vm_sa_compute_viewer
module.iam.google_project_iam_member.vm_sa_logging_writer
module.iam.google_project_iam_member.vm_sa_monitoring_writer
module.iam.google_project_iam_member.vm_sa_storage_viewer
module.iam.google_service_account.vm_service_account
module.network.google_compute_network.vpc
module.network.google_compute_router.router
module.network.google_compute_router_nat.nat
module.network.google_compute_subnetwork.subnet
module.security.google_compute_firewall.allow_health_check
module.security.google_compute_firewall.allow_http_https
module.security.google_compute_firewall.allow_internal
module.security.google_compute_firewall.allow_ssh
```

### 2. `terraform state show <resource>`
**Purpose**: Shows detailed information about a specific resource
**Usage**: `terraform state show module.compute.google_compute_instance.vm`
**Output**: Complete resource configuration and current state

### 3. `terraform workspace list`
**Purpose**: Shows all available workspaces
**Usage**: `terraform workspace list`
**Current**: You're using `dev` workspace (indicated by *)

### 4. `terraform workspace show`
**Purpose**: Shows current active workspace
**Usage**: `terraform workspace show`
**Output**: `dev`

### 5. `terraform output`
**Purpose**: Shows all output values from your configuration
**Usage**: `terraform output`
**Alternative**: `terraform output <output_name>` for specific output

### 6. `terraform plan`
**Purpose**: Shows what changes Terraform would make
**Usage**: `terraform plan`
**Safe**: Read-only operation, doesn't change anything

### 7. `terraform apply`
**Purpose**: Applies changes to match your configuration
**Usage**: `terraform apply`
**Caution**: Makes actual changes to infrastructure

### 8. `terraform destroy`
**Purpose**: Destroys all managed infrastructure
**Usage**: `terraform destroy`
**Danger**: Permanently deletes resources

### 9. `terraform refresh`
**Purpose**: Updates state file with real-world resource status
**Usage**: `terraform refresh`
**Note**: Deprecated in newer versions, use `terraform plan -refresh-only`

### 10. `terraform import <resource> <id>`
**Purpose**: Imports existing resources into Terraform state
**Usage**: `terraform import module.iam.google_iam_workload_identity_pool.pool projects/praxis-gear-483220-k4/locations/global/workloadIdentityPools/github-pool`

## State File Structure

### Workspace Structure
```
terraform.tfstate.d/
└── dev/
    ├── terraform.tfstate        # Current state
    └── terraform.tfstate.backup # Previous state backup
```

### State File Contents
- **Resource mappings**: Links Terraform config to real resources
- **Resource metadata**: IDs, properties, dependencies
- **Provider information**: Which provider manages each resource
- **Workspace data**: Environment-specific configurations

## Common State Operations

### Check Resource Details
```bash
# List all resources
terraform state list

# Show specific resource
terraform state show module.compute.google_compute_instance.vm

# Show all outputs
terraform output
```

### Workspace Management
```bash
# List workspaces
terraform workspace list

# Show current workspace
terraform workspace show

# Create new workspace
terraform workspace new prod

# Switch workspace
terraform workspace select dev
```

### State Troubleshooting
```bash
# Refresh state from real resources
terraform plan -refresh-only

# Validate configuration
terraform validate

# Format configuration files
terraform fmt

# Check for configuration issues
terraform plan
```

## Interview Questions & Answers

### Q: What is Terraform state and why is it important?
**A**: Terraform state is a JSON file that maps your configuration to real-world resources. It's crucial because:
- Tracks resource metadata and dependencies
- Enables Terraform to know what it manages
- Stores sensitive data like resource IDs
- Enables collaboration through remote state
- Provides performance optimization by caching resource attributes

### Q: Where are state files stored in your project?
**A**: In our project, we use Terraform workspaces:
- State files are in `terraform.tfstate.d/dev/terraform.tfstate`
- We have a `dev` workspace for development environment
- Backup files are automatically created as `terraform.tfstate.backup`
- For production, we'd use remote state in GCS bucket

### Q: How do you check what resources are currently deployed?
**A**: Use `terraform state list` to see all managed resources. Our project currently has 15 resources deployed across 4 modules: network (4 resources), security (4 firewalls), IAM (4 resources), and compute (1 VM).

### Q: What's the difference between terraform plan and terraform apply?
**A**: 
- `terraform plan`: Read-only operation that shows what changes would be made
- `terraform apply`: Actually executes the changes to create/modify/destroy resources
- Always run `plan` first to review changes before `apply`

### Q: How do you handle state in team environments?
**A**: Use remote state backends like GCS:
- Store state in Google Cloud Storage bucket
- Enable state locking to prevent concurrent modifications
- Use workspaces for different environments (dev, staging, prod)
- Never commit state files to version control

## Best Practices

1. **Always backup state**: Terraform creates backups automatically
2. **Use remote state**: For team collaboration and security
3. **Use workspaces**: Separate environments (dev, staging, prod)
4. **Regular state refresh**: Keep state synchronized with reality
5. **State locking**: Prevent concurrent modifications
6. **Never edit state manually**: Use Terraform commands only
7. **Version control**: Keep configuration files in Git, not state files

## Your Project Status
✅ **Infrastructure Deployed**: 15 resources successfully created
✅ **Workspace**: Using `dev` workspace
✅ **State Location**: `terraform.tfstate.d/dev/terraform.tfstate`
✅ **WIF Setup**: Workload Identity Federation configured and working
✅ **Network**: VPC, subnet, NAT gateway deployed
✅ **Security**: Firewall rules configured
✅ **Compute**: VM instance running
✅ **IAM**: Service accounts and permissions configured