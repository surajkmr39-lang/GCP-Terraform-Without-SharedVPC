# 🎯 TERRAFORM INTERVIEW PREPARATION - PART 6: QUICK REFERENCE

## 📋 CHEAT SHEET - MEMORIZE THESE

### **Project Stats (Memorize These Numbers)**
- **4 modules**: network, iam, security, compute
- **15 resources** created
- **$18-24/month** cost
- **2-3 minutes** deployment time
- **256 IPs** in subnet (10.0.1.0/24)
- **3 CI/CD workflows**: test, deploy, full pipeline
- **5 authentication labs**: ADC, Keys, Impersonation, WIF, GitHub Actions
- **Zero stored keys** (WIF)

### **File Structure - Quick Answer**
```
Root Files (Orchestrator):
├── main.tf          → Calls all modules
├── variables.tf     → Declares inputs
├── outputs.tf       → Displays results
└── terraform.tfvars → Your values (gitignored)

Module Files (Workers):
├── modules/network/
│   ├── main.tf      → Creates VPC, subnet, NAT
│   ├── variables.tf → What network needs
│   └── outputs.tf   → vpc_name, subnet_name
```

### **Data Flow - One Sentence**
"User provides values in terraform.tfvars → Root variables.tf declares them → Root main.tf passes to modules → Modules create resources → Modules output results → Root outputs.tf displays them"

---

## 🔥 TOP 10 MUST-KNOW ANSWERS

### **1. "What is Terraform?"**
"Terraform is an Infrastructure as Code tool that lets you define cloud resources in declarative configuration files, then automatically creates, updates, or destroys them to match your desired state."

### **2. "Why use modules?"**
"Modules provide reusability, organization, and maintainability. Same network module works for dev, staging, and prod with different variables. Changes to one module don't affect others."

### **3. "What is state file?"**
"Terraform's memory of what it created. Maps code to real resources, tracks dependencies, enables planning. Must be protected - contains sensitive data. Use remote backend with encryption."

### **4. "Implicit vs explicit dependencies?"**
"Implicit: Terraform detects via resource references (network = vpc.id). Explicit: Manual depends_on. Prefer implicit - it's automatic and clear."

### **5. "What is WIF?"**
"Workload Identity Federation - keyless authentication for external workloads. GitHub Actions gets OIDC token, exchanges for temporary GCP credentials. No stored keys, auto-rotation, repository-specific."

### **6. "How do you handle secrets?"**
"Never in code. Use terraform.tfvars (gitignored), environment variables, Secret Manager, mark as sensitive, encrypt state, restrict access."

### **7. "What if apply fails halfway?"**
"Terraform updates state for successful resources, reports error, next apply continues from failure point. Idempotent - safe to re-run."

### **8. "Multiple environments?"**
"Workspaces + environment-specific tfvars files. Same code, different configurations. Separate state files prevent accidental prod changes."

### **9. "How do you test?"**
"Static analysis (fmt, validate, tflint, checkov), plan review, module testing (Terratest), integration testing, compliance checks. All automated in CI/CD."

### **10. "Your biggest achievement in this project?"**
"Implementing Workload Identity Federation for keyless CI/CD. Eliminated security risk of stored credentials, automated deployments, followed modern best practices."

---

## 🎯 TECHNICAL TERMS - KNOW THESE COLD

### **Terraform Concepts**
- **Resource**: Single infrastructure object (VM, VPC)
- **Module**: Container for multiple resources
- **Provider**: Plugin for cloud platform (google, aws)
- **State**: Terraform's memory of infrastructure
- **Backend**: Where state is stored (local, GCS, S3)
- **Workspace**: Separate state instances
- **Output**: Values exposed after apply
- **Variable**: Input parameter
- **Data Source**: Read-only information
- **Provisioner**: Execute scripts (avoid if possible)

### **GCP Concepts**
- **VPC**: Virtual Private Cloud - isolated network
- **Subnet**: IP range within VPC
- **Cloud NAT**: Network Address Translation for outbound
- **Service Account**: Identity for applications
- **IAM**: Identity and Access Management
- **WIF**: Workload Identity Federation
- **OIDC**: OpenID Connect - authentication protocol
- **Shielded VM**: Hardened VM with secure boot
- **VPC Flow Logs**: Network traffic logs

### **DevOps Concepts**
- **IaC**: Infrastructure as Code
- **CI/CD**: Continuous Integration/Deployment
- **Idempotent**: Same result regardless of runs
- **Declarative**: Describe desired state, not steps
- **Immutable**: Replace, don't modify
- **GitOps**: Git as single source of truth

---

## 💡 IMPRESSIVE THINGS TO MENTION

### **Security Highlights**
✅ "Zero stored credentials using WIF"
✅ "Shielded VMs with secure boot and vTPM"
✅ "Least-privilege IAM with specific roles"
✅ "VPC Flow Logs for security monitoring"
✅ "Automated security scanning with Checkov"
✅ "State file encrypted in GCS"
✅ "Private subnets with NAT gateway"

### **Best Practices Implemented**
✅ "Modular architecture for reusability"
✅ "Remote state with locking"
✅ "Environment-specific configurations"
✅ "Comprehensive documentation"
✅ "CI/CD with automated testing"
✅ "Cost optimization (~$20/month)"
✅ "Infrastructure as Code principles"

### **Modern DevOps Patterns**
✅ "GitOps workflow - all changes via Git"
✅ "Keyless authentication with OIDC"
✅ "Automated compliance checking"
✅ "Infrastructure testing in pipeline"
✅ "Immutable infrastructure"
✅ "Policy as Code"

---

## 🚨 RED FLAGS TO AVOID

### **Don't Say These**
❌ "I hardcoded credentials in the code"
❌ "I don't use modules, everything in one file"
❌ "State file is in Git"
❌ "I manually create resources in console"
❌ "I don't test Terraform code"
❌ "I use admin permissions for everything"
❌ "I don't know what WIF is"
❌ "I've never used CI/CD with Terraform"

### **Instead Say**
✅ "I use Secret Manager and mark variables sensitive"
✅ "I created 4 reusable modules"
✅ "State is in GCS with encryption and locking"
✅ "All infrastructure is managed by Terraform"
✅ "I have automated testing in CI/CD"
✅ "I follow least-privilege principle"
✅ "I implemented WIF for keyless authentication"
✅ "I have a complete CI/CD pipeline with GitHub Actions"

---

## 🎤 OPENING STATEMENT TEMPLATES

### **Template 1: Technical Focus**
"I built a production-ready GCP infrastructure using Terraform with a modular architecture. The project demonstrates Infrastructure as Code best practices including reusable modules, remote state management, and automated CI/CD deployment using Workload Identity Federation for keyless authentication."

### **Template 2: Security Focus**
"I designed a secure GCP environment using Terraform with zero stored credentials. The implementation uses Workload Identity Federation for GitHub Actions, Shielded VMs with secure boot, least-privilege IAM roles, and automated security scanning in the CI/CD pipeline."

### **Template 3: DevOps Focus**
"I implemented a complete DevOps workflow for GCP infrastructure using Terraform and GitHub Actions. The project features modular code organization, environment-specific configurations, automated testing and deployment, and comprehensive documentation for team collaboration."

### **Template 4: Business Value Focus**
"I created a cost-effective GCP infrastructure (~$20/month) using Terraform that provides a complete development environment with enterprise-grade security, automated deployments, and 99.9% SLA. The modular design allows rapid replication across multiple environments."

---

## 📊 METRICS TO MENTION

### **Performance**
- Deployment time: 2-3 minutes
- Resource count: 15 resources
- Module count: 4 modules
- Lines of code: ~500 lines

### **Cost**
- Monthly cost: $18-24
- Cost per resource: ~$1.50
- Optimization: Right-sized instances
- Monitoring: Budget alerts configured

### **Security**
- Zero stored keys
- 4 firewall rules
- Least-privilege IAM
- Automated scanning
- Compliance: CIS benchmarks

### **Reliability**
- SLA: 99.9%
- Backup: State versioning
- Recovery: Documented procedures
- Testing: Automated in CI/CD

---

## 🎯 CLOSING STATEMENT

### **When They Ask: "Any questions for us?"**

**Good Questions to Ask**:
1. "What's your current infrastructure management approach - manual, scripts, or IaC?"
2. "Do you use Terraform or considering migration to it?"
3. "What's your strategy for multi-cloud or hybrid cloud?"
4. "How do you handle secrets management in your infrastructure?"
5. "What's your CI/CD pipeline for infrastructure changes?"
6. "Do you use Workload Identity Federation or service account keys?"
7. "What's your approach to infrastructure testing and validation?"
8. "How do you manage infrastructure across multiple environments?"

**Confident Closing**:
"I'm excited about this opportunity because I'm passionate about Infrastructure as Code and modern DevOps practices. This project demonstrates my ability to design secure, scalable, and cost-effective cloud infrastructure. I'm eager to bring these skills to your team and learn from your infrastructure challenges."

---

## 🔑 FINAL TIPS

### **During Interview**
1. **Speak confidently** - You built this, you know it
2. **Use diagrams** - Draw architecture if possible
3. **Give examples** - Reference specific code
4. **Show enthusiasm** - Talk about what you learned
5. **Be honest** - Say "I don't know but I'd research it" if stuck

### **Before Interview**
1. Run `terraform plan` - refresh your memory
2. Review all 6 interview guide parts
3. Practice explaining architecture out loud
4. Prepare to demo live if asked
5. Review your GitHub Actions workflows

### **Red Flags They Look For**
- Can't explain own code
- No understanding of security
- No testing strategy
- Manual processes
- Hardcoded values
- No documentation

### **Green Flags They Want**
- Clear architecture explanation
- Security-first mindset
- Automated everything
- Best practices followed
- Good documentation
- Continuous learning

---

## 🎓 STUDY PLAN (Day Before Interview)

### **Morning (2 hours)**
- Read Part 1: Core Concepts
- Read Part 2: Code Walkthrough
- Practice explaining variable flow

### **Afternoon (2 hours)**
- Read Part 3: Advanced Questions
- Read Part 4: Scenario Questions
- Practice state management answers

### **Evening (1 hour)**
- Read Part 5: Project Demo
- Read Part 6: Quick Reference (this file)
- Memorize project stats

### **Night Before**
- Review architecture diagram
- Practice 5-minute project overview
- Get good sleep!

---

**YOU'RE READY! 🚀**

You have:
- ✅ Complete project understanding
- ✅ All code explanations
- ✅ Scenario-based answers
- ✅ Demo script ready
- ✅ Quick reference memorized

**Go ace that interview!**
