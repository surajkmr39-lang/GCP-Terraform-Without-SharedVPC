# 🔑 SSH Key Setup Guide for GCP Infrastructure

## 🎯 **Enterprise SSH Key Management**

This guide explains how to properly configure SSH access for your GCP infrastructure following enterprise security practices.

## 🔧 **SSH Key Generation**

### **1. Generate SSH Key Pair**
```bash
# Generate a new SSH key pair (recommended: Ed25519)
ssh-keygen -t ed25519 -C "your-email@company.com" -f ~/.ssh/gcp-terraform-key

# Or use RSA if Ed25519 is not supported
ssh-keygen -t rsa -b 4096 -C "your-email@company.com" -f ~/.ssh/gcp-terraform-key
```

### **2. Set Proper Permissions**
```bash
chmod 600 ~/.ssh/gcp-terraform-key
chmod 644 ~/.ssh/gcp-terraform-key.pub
```

## 🏢 **Enterprise Configuration**

### **Development Environment**
```bash
# Copy public key content
cat ~/.ssh/gcp-terraform-key.pub

# Add to environments/dev/terraform.tfvars
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGq... your-email@company.com"
ssh_user       = "your-username"
```

### **Production Environment**
```bash
# For production, use centralized key management
# Add to environments/prod/terraform.tfvars
ssh_public_key = ""  # Leave empty to use OS Login
ssh_user       = ""  # OS Login manages users
```

## 🔐 **Security Best Practices**

### **1. OS Login (Recommended for Production)**
```bash
# Enable OS Login for centralized SSH management
gcloud compute project-info add-metadata \
    --metadata enable-oslogin=TRUE

# Grant OS Login access to users
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member=user:user@company.com \
    --role=roles/compute.osLogin
```

### **2. SSH Source IP Restrictions**

**Development Environment:**
```hcl
# Allow from private networks only
ssh_source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
```

**Production Environment:**
```hcl
# Restrict to office/VPN networks only
ssh_source_ranges = ["203.0.113.0/24", "198.51.100.0/24"]  # Replace with your actual IPs
```

### **3. SSH Configuration File**
```bash
# Create ~/.ssh/config for easy access
cat >> ~/.ssh/config << EOF
Host gcp-dev-vm
    HostName DEVELOPMENT_VM_IP
    User your-username
    IdentityFile ~/.ssh/gcp-terraform-key
    StrictHostKeyChecking yes

Host gcp-prod-vm
    HostName PRODUCTION_VM_IP
    User your-username
    IdentityFile ~/.ssh/gcp-terraform-key
    StrictHostKeyChecking yes
EOF
```

## 🚀 **Connection Methods**

### **Method 1: Direct SSH (Development)**
```bash
# Connect using SSH key
ssh -i ~/.ssh/gcp-terraform-key username@VM_EXTERNAL_IP

# Or using SSH config
ssh gcp-dev-vm
```

### **Method 2: gcloud SSH (Recommended)**
```bash
# Connect using gcloud (works with OS Login)
gcloud compute ssh development-vm \
    --zone=us-central1-a \
    --project=praxis-gear-483220-k4

# For production
gcloud compute ssh production-vm \
    --zone=us-central1-b \
    --project=praxis-gear-483220-k4
```

### **Method 3: IAP Tunneling (Most Secure)**
```bash
# Connect through Identity-Aware Proxy (no external IP needed)
gcloud compute ssh development-vm \
    --zone=us-central1-a \
    --project=praxis-gear-483220-k4 \
    --tunnel-through-iap
```

## 🔧 **Terraform Configuration**

### **Update terraform.tfvars Files**

**For Development:**
```hcl
ssh_user       = "your-username"
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGq... your-email@company.com"
```

**For Production (OS Login):**
```hcl
ssh_user       = ""  # OS Login manages users
ssh_public_key = ""  # OS Login manages keys
```

## 🛡️ **Security Considerations**

### **Key Rotation**
```bash
# Rotate SSH keys regularly (quarterly recommended)
ssh-keygen -t ed25519 -C "your-email@company.com" -f ~/.ssh/gcp-terraform-key-new

# Update Terraform configuration
# Apply changes to rotate keys
terraform apply
```

### **Access Auditing**
```bash
# Monitor SSH access logs
gcloud logging read "resource.type=gce_instance AND jsonPayload.message:ssh" \
    --limit=50 \
    --format="table(timestamp,jsonPayload.message)"
```

### **Emergency Access**
```bash
# In case of key loss, use serial console
gcloud compute connect-to-serial-port development-vm \
    --zone=us-central1-a \
    --project=praxis-gear-483220-k4
```

## 📋 **Troubleshooting**

### **Common Issues:**

**1. Permission Denied**
```bash
# Check key permissions
ls -la ~/.ssh/gcp-terraform-key*

# Fix permissions
chmod 600 ~/.ssh/gcp-terraform-key
```

**2. Key Not Accepted**
```bash
# Verify public key format
ssh-keygen -l -f ~/.ssh/gcp-terraform-key.pub

# Check VM metadata
gcloud compute instances describe development-vm \
    --zone=us-central1-a \
    --format="value(metadata.items[ssh-keys])"
```

**3. Connection Timeout**
```bash
# Check firewall rules
gcloud compute firewall-rules list --filter="name:ssh"

# Verify source IP ranges
curl -s https://ipinfo.io/ip  # Check your current IP
```

## 🎯 **Enterprise Recommendations**

1. **Use OS Login for production environments**
2. **Implement SSH key rotation policies**
3. **Restrict SSH access to specific IP ranges**
4. **Use IAP tunneling for enhanced security**
5. **Monitor and audit SSH access logs**
6. **Implement break-glass procedures for emergency access**

This SSH setup ensures secure, auditable, and manageable access to your GCP infrastructure following enterprise security standards.