# 🚀 GCP Infrastructure with Terraform

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform&logoColor=white)](https://terraform.io)
[![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?logo=google-cloud&logoColor=white)](https://cloud.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Enterprise-grade Google Cloud Platform infrastructure deployment using Terraform with modular architecture, security hardening, and workload identity federation.

**Author**: Suraj Kumar

## 📋 Project Overview

This project demonstrates the deployment of a secure, scalable development environment on Google Cloud Platform using Infrastructure as Code principles. The implementation follows enterprise best practices with comprehensive security features and cost optimization.

### 🎯 Key Features

- **Modular Architecture**: 4 reusable Terraform modules
- **Security First**: Shielded VMs, Workload Identity, VPC security
- **Cost Optimized**: ~$18-24/month for complete environment
- **Enterprise Ready**: Compliance with security standards
- **CI/CD Integration**: GitHub Actions with Workload Identity Federation

## 🏗️ Architecture

```
🌐 Internet → 🛡️ Firewall → 🔄 Cloud NAT → 📡 VPC → 💻 VM Instance
                                                    ↓
                              🔐 Service Account ← 🔑 Workload Identity
```

### Infrastructure Components

| Component | Resource | Configuration |
|-----------|----------|---------------|
| **Network** | VPC + Subnet | `dev-vpc` with `10.0.1.0/24` |
| **Compute** | VM Instance | `e2-medium` Ubuntu 22.04 + Docker |
| **Security** | Firewall Rules | SSH, HTTP/HTTPS, Internal |
| **Identity** | Service Account | Workload Identity Federation |
| **Networking** | Cloud NAT | Secure outbound internet access |

## 📁 Project Structure

```
├── main.tf                           # Root Terraform configuration
├── variables.tf                      # Variable definitions
├── outputs.tf                        # Output definitions
├── terraform.tfvars.example          # Example variables file
├── Makefile                          # Build automation commands
├── Check-WIF-Status.ps1              # WIF validation script
├── architecture-diagram.py           # Generate architecture diagram
├── .github/workflows/                # CI/CD pipelines
│   ├── cicd-pipeline.yml            # Main CI/CD workflow
│   ├── deploy-infrastructure.yml    # Deployment workflow
│   └── test-wif-auth.yml            # WIF authentication test
├── modules/                          # Terraform modules
│   ├── network/                      # VPC, subnets, NAT gateway
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/                     # Firewall rules
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── iam/                          # Service accounts, workload identity
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── compute/                      # VM instances
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/                     # Environment-specific configs
│   ├── dev/terraform.tfvars          # Development configuration
│   ├── staging/terraform.tfvars      # Staging configuration
│   └── prod/terraform.tfvars         # Production configuration
├── labs/                             # Authentication practice labs
│   ├── phase-1-adc/                  # Application Default Credentials
│   ├── phase-2-service-account-keys/ # Service Account Keys
│   ├── phase-3-impersonation/        # Service Account Impersonation
│   ├── phase-4-workload-identity/    # Workload Identity Federation
│   └── phase-5-github-actions-wif/   # GitHub Actions with WIF
└── docs/                             # Documentation & diagrams
    ├── README.md                     # This file
    ├── SETUP.md                      # Setup instructions
    ├── CICD-PIPELINE-GUIDE.md        # CI/CD documentation
    ├── WIF-QUICK-REFERENCE.md        # WIF reference guide
    ├── gcp-architecture-diagram.png  # Architecture diagram (generated)
    └── *.py                          # Diagram generator scripts
```
```

## 🚀 Quick Start

### Prerequisites

1. **Google Cloud SDK**
   ```bash
   # Install and authenticate
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Terraform >= 1.0**
   ```bash
   # Install Terraform
   # macOS: brew install terraform
   # Windows: choco install terraform
   ```

3. **Enable Required APIs**
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable iam.googleapis.com
   gcloud services enable iamcredentials.googleapis.com
   gcloud services enable cloudresourcemanager.googleapis.com
   ```

### Deployment

1. **Clone Repository**
   ```bash
   git clone https://github.com/surajkmr39-lang/GCP-Terraform.git
   cd GCP-Terraform
   ```

2. **Configure Environment**
   ```bash
   cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
   # Edit with your project details
   ```

3. **Deploy Infrastructure**
   ```bash
   # Using Makefile (recommended)
   make init
   make dev-plan
   make dev-apply

   # Or manually
   terraform init
   terraform workspace new dev
   terraform plan -var-file="environments/dev/terraform.tfvars"
   terraform apply -var-file="environments/dev/terraform.tfvars"
   ```

4. **Connect to VM**
   ```bash
   # Get SSH command from output
   terraform output
   
   # Connect to VM
   gcloud compute ssh dev-vm --zone=us-central1-a --project=YOUR_PROJECT_ID
   ```

## 🔐 Security Features

### VM Security
- ✅ **Shielded VM**: Secure boot, vTPM, integrity monitoring
- ✅ **OS Login**: Centralized SSH key management
- ✅ **Metadata Security**: Block project SSH keys
- ✅ **Service Account**: Minimal required permissions

### Network Security
- ✅ **Private Subnet**: No direct internet access
- ✅ **Cloud NAT**: Controlled outbound access
- ✅ **Firewall Rules**: Least privilege access
- ✅ **VPC Flow Logs**: Network monitoring

### Identity Security
- ✅ **Workload Identity**: No stored service account keys
- ✅ **IAM Roles**: Principle of least privilege
- ✅ **GitHub Integration**: Secure CI/CD authentication

## 💰 Cost Analysis

| Resource | Monthly Cost |
|----------|-------------|
| VM Instance (e2-medium) | $13-16 |
| Persistent Disk (20GB SSD) | $3 |
| External IP | $3 |
| Cloud NAT | $1-2 |
| Network Egress | $1-3 |
| **Total** | **$18-24** |

### Cost Optimization
- Use preemptible instances for dev (-60% cost)
- Implement auto-shutdown schedules
- Monitor network egress usage
- Use committed use discounts for production

## 🛠️ Usage Examples

### Environment Management
```bash
# Development
make dev-plan
make dev-apply

# Staging
make staging-plan
make staging-apply

# Production
make prod-plan
make prod-apply
```

### Infrastructure Operations
```bash
# View outputs
make output ENV=dev

# Destroy environment
make destroy ENV=dev

# Format code
make format

# Validate configuration
make validate
```

## 🔧 Customization

### VM Configuration
Edit `environments/{env}/terraform.tfvars`:
```hcl
machine_type = "e2-standard-2"  # Upgrade VM size
disk_size    = 50               # Increase disk size
vm_image     = "ubuntu-os-cloud/ubuntu-2204-lts"
```

### Network Configuration
```hcl
subnet_cidr       = "10.1.1.0/24"     # Change subnet range
ssh_source_ranges = ["YOUR_IP/32"]     # Restrict SSH access
```

### Security Configuration
```hcl
github_repository = "your-org/your-repo"  # Enable workload identity
```

## 📊 Monitoring & Maintenance

### Health Checks
- VM instance status and performance
- Network connectivity and throughput
- Service account permissions audit
- Cost and usage monitoring

### Regular Tasks
- **Weekly**: Security updates and patches
- **Monthly**: Cost optimization review
- **Quarterly**: Infrastructure and security audit

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Terraform best practices
- Update documentation for any changes
- Test in development environment first
- Use conventional commit messages

## 📚 Documentation

- [Setup Guide](docs/SETUP.md) - Detailed setup instructions
- [Deployment Success](docs/DEPLOYMENT_SUCCESS.md) - Deployment results and verification
- [Process Explanation](docs/TERRAFORM_PROCESS_EXPLANATION.md) - Complete technical documentation
- [Presentation](presentation/) - PowerPoint presentation and speaker notes

## 🎤 Presentation

This repository includes a comprehensive presentation package:
- **PowerPoint Presentation**: 16 professional slides
- **Speaker Notes**: Detailed presentation guide
- **Architecture Diagrams**: Visual infrastructure representations

Perfect for technical presentations, architecture reviews, and stakeholder meetings.

## 🐛 Troubleshooting

### Common Issues

**Terraform Init Fails**
```bash
rm -rf .terraform/
terraform init
```

**Authentication Issues**
```bash
gcloud auth list
gcloud auth application-default login
```

**API Not Enabled**
```bash
gcloud services enable compute.googleapis.com
```

**SSH Connection Issues**
```bash
gcloud compute firewall-rules list
gcloud compute instances list
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Google Cloud Platform for excellent documentation
- Terraform community for best practices
- HashiCorp for the amazing Terraform tool

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/surajkmr39-lang/GCP-Terraform/issues)
- **Discussions**: [GitHub Discussions](https://github.com/surajkmr39-lang/GCP-Terraform/discussions)
- **Email**: surajkmr39.lang@gmail.com

---

**Created by**: Suraj Kumar  
**⭐ If this project helped you, please give it a star!**

**🚀 Infrastructure as Code | 🔐 Security First | 💰 Cost Optimized**