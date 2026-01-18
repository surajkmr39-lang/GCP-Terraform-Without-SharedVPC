# 📋 Terraform State Management Commands

## 🌍 Multi-Environment State Operations

### 🔧 **Development Environment**
```bash
cd environments/dev

# Initialize remote backend
terraform init

# View state
terraform state list
terraform state show <resource_name>

# State operations
terraform plan
terraform apply
terraform destroy

# State file location
# gs://praxis-gear-483220-k4-terraform-state/environments/development/terraform-state/
```

### 🟡 **Staging Environment**
```bash
cd environments/staging

# Initialize remote backend
terraform init

# View state
terraform state list
terraform state show <resource_name>

# State operations
terraform plan
terraform apply
terraform destroy

# State file location
# gs://praxis-gear-483220-k4-terraform-state/environments/staging/terraform-state/
```

### 🔴 **Production Environment**
```bash
cd environments/prod

# Initialize remote backend
terraform init

# View state
terraform state list
terraform state show <resource_name>

# State operations
terraform plan
terraform apply
terraform destroy

# State file location
# gs://praxis-gear-483220-k4-terraform-state/environments/production/terraform-state/
```

## 🔍 **State Inspection Commands**

### **List All Resources**
```bash
terraform state list
```

### **Show Specific Resource**
```bash
terraform state show module.compute.google_compute_instance.vm
terraform state show module.network.google_compute_network.vpc
terraform state show module.iam.google_iam_workload_identity_pool.pool
```

### **State File Information**
```bash
terraform show
terraform output
terraform refresh
```

## 🔄 **State Management Operations**

### **Import Existing Resources**
```bash
terraform import module.compute.google_compute_instance.vm projects/PROJECT_ID/zones/ZONE/instances/INSTANCE_NAME
```

### **Remove Resources from State**
```bash
terraform state rm module.compute.google_compute_instance.vm
```

### **Move Resources in State**
```bash
terraform state mv module.old_name module.new_name
```

### **Pull Remote State**
```bash
terraform state pull
```

### **Push Local State to Remote**
```bash
terraform state push
```

## 🔒 **State Locking**

### **Force Unlock (if needed)**
```bash
terraform force-unlock LOCK_ID
```

### **Check Lock Status**
```bash
# State locking is automatic with GCS backend
# Lock information is stored in the state file metadata
```

## 🌐 **GCS Backend Commands**

### **View State Files in GCS**
```bash
gsutil ls gs://praxis-gear-483220-k4-terraform-state/
gsutil ls gs://praxis-gear-483220-k4-terraform-state/environments/
gsutil ls gs://praxis-gear-483220-k4-terraform-state/environments/development/terraform-state/
gsutil ls gs://praxis-gear-483220-k4-terraform-state/environments/staging/terraform-state/
gsutil ls gs://praxis-gear-483220-k4-terraform-state/environments/production/terraform-state/
```

### **Download State File**
```bash
gsutil cp gs://praxis-gear-483220-k4-terraform-state/environments/development/terraform-state/default.tfstate ./
```

### **View State File Versions**
```bash
gsutil ls -a gs://praxis-gear-483220-k4-terraform-state/environments/development/terraform-state/
```

## 🎯 **Best Practices**

### **Always Use Remote State for Team Collaboration**
- ✅ Enables multiple developers to work on same infrastructure
- ✅ Provides state locking to prevent conflicts
- ✅ Automatic backups and versioning
- ✅ Centralized state management

### **Environment Separation**
- ✅ Separate state files for each environment
- ✅ Different GCS prefixes for isolation
- ✅ Environment-specific configurations
- ✅ Independent deployment workflows

### **State Security**
- ✅ GCS bucket with proper IAM permissions
- ✅ State file encryption at rest
- ✅ Access logging and monitoring
- ✅ Regular state file backups

## 🚨 **Troubleshooting**

### **State Lock Issues**
```bash
# If state is locked and you need to force unlock
terraform force-unlock <LOCK_ID>

# Check for stale locks
terraform plan  # Will show lock information if locked
```

### **State Corruption**
```bash
# Restore from backup
gsutil cp gs://praxis-gear-483220-k4-terraform-state/environments/development/terraform-state/default.tfstate.backup ./terraform.tfstate

# Or restore from specific version
gsutil cp gs://praxis-gear-483220-k4-terraform-state/environments/development/terraform-state/default.tfstate#<generation> ./terraform.tfstate
```

### **Backend Configuration Issues**
```bash
# Reconfigure backend
terraform init -reconfigure

# Migrate state to new backend
terraform init -migrate-state
```