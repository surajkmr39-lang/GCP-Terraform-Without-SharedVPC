# 🧪 GCP Authentication Labs - 5-Phase Mastery Series

**Author**: Suraj Kumar  
**Project**: Enterprise GCP Authentication Mastery  
**Status**: ✅ Complete series with **Phase 4 (WIF) actively deployed**  
**Duration**: 4-6 hours total (1-2 hours per phase)

## 🎯 Lab Series Overview

This hands-on lab series takes you from basic authentication to enterprise-grade security practices using your existing GCP Terraform project. **Phase 4 (Workload Identity Federation) is currently deployed and operational** in the main project.

### ✅ Current Implementation Status
- **Active Method**: Workload Identity Federation (Phase 4)
- **WIF Pool**: `github-pool` (deployed and operational)
- **Service Account**: `dev-vm-sa@praxis-gear-483220-k4.iam.gserviceaccount.com`
- **GitHub Integration**: Ready for `surajkmr39-lang/GCP-Terraform` repository
- **Security Level**: ⭐⭐⭐⭐⭐ Enterprise Grade

### 📚 What You'll Learn
- 5 different GCP authentication methods (including GitHub Actions)
- Real-world enterprise security patterns
- Hands-on implementation with your infrastructure
- Troubleshooting and best practices
- Production-ready knowledge with live examples

### 🏗️ Lab Structure
Each phase builds on the previous one, using your existing Terraform modules and infrastructure.

## 📋 Prerequisites

✅ **Completed Setup**
- Your GCP project: `praxis-gear-483220-k4`
- Terraform infrastructure deployed
- `gcloud` CLI configured
- GitHub account (for Phase 4)

✅ **Current State**
- ADC authentication working (`gcloud auth application-default login`)
- Infrastructure deployed in dev environment
- VM accessible via SSH

## 🎪 Lab Phases

### **Phase 1: Application Default Credentials (ADC)** ⭐
**Duration**: 30 minutes  
**Current State**: ✅ Already implemented  
**Focus**: Understanding and optimizing your current setup

### **Phase 2: Service Account Key Files** ⭐⭐
**Duration**: 45 minutes  
**Focus**: Traditional approach, security risks, and when to use

### **Phase 3: Service Account Impersonation** ⭐⭐⭐
**Duration**: 1 hour  
**Focus**: Secure cross-environment access, enterprise patterns

### **Phase 4: Workload Identity Federation** ⭐⭐⭐⭐
**Duration**: 1.5 hours  
**Focus**: Keyless authentication, CI/CD integration, multi-cloud

## 🚀 Quick Start

1. **Clone/Navigate to your project**:
   ```bash
   cd GCP-Terraform-7th-Jan-2026
   ```

2. **Start with Phase 1**:
   ```bash
   # Navigate to labs directory
   cd labs/phase-1-adc
   
   # Follow the README instructions
   ```

3. **Progress through phases sequentially**

## 📊 Learning Outcomes

| Phase | Authentication Method | Security Level | Enterprise Use | Skills Gained |
|-------|----------------------|----------------|----------------|---------------|
| 1 | ADC | ⭐⭐ | Development | Basic auth, troubleshooting |
| 2 | Service Account Keys | ⭐ | Legacy/Simple | Key management, security risks |
| 3 | Impersonation | ⭐⭐⭐⭐ | Production | Cross-env access, audit trails |
| 4 | Workload Identity | ⭐⭐⭐⭐⭐ | Enterprise | Keyless auth, CI/CD integration |

## 🎯 Real-World Scenarios

Each lab includes:
- **Problem Statement**: Real enterprise challenge
- **Implementation**: Step-by-step solution
- **Verification**: How to test and validate
- **Troubleshooting**: Common issues and fixes
- **Technical Questions**: What employers ask

## 📁 Lab Directory Structure

```
labs/
├── README.md                          # This file
├── phase-1-adc/
│   ├── README.md                      # ADC deep dive
│   ├── troubleshooting-guide.md       # Common ADC issues
│   └── verification-scripts/          # Test scripts
├── phase-2-service-account-keys/
│   ├── README.md                      # Key-based auth
│   ├── security-analysis.md           # Risk assessment
│   └── key-management-demo/           # Hands-on examples
├── phase-3-impersonation/
│   ├── README.md                      # Impersonation setup
│   ├── cross-environment-demo/        # Multi-env access
│   └── enterprise-patterns/           # Real-world examples
└── phase-4-workload-identity/
    ├── README.md                      # WIF implementation
    ├── github-actions-demo/           # CI/CD integration
    ├── multi-cloud-examples/          # AWS/Azure integration
    └── advanced-scenarios/            # Complex use cases
```

## 🏆 Completion Rewards

After completing all phases, you'll have:
- ✅ **Portfolio Project**: Enterprise-grade authentication setup
- ✅ **Professional Confidence**: Deep understanding of GCP security
- ✅ **Real Experience**: Hands-on with all major auth methods
- ✅ **Best Practices**: Production-ready security patterns
- ✅ **Troubleshooting Skills**: Ability to debug auth issues

## 🚨 Important Notes

- **Backup First**: Each phase includes backup/restore procedures
- **Cost Awareness**: Labs use existing infrastructure (minimal additional cost)
- **Security**: Never commit keys or credentials to git
- **Clean Up**: Each phase includes cleanup instructions

## 🆘 Getting Help

- **Stuck?** Check the troubleshooting section in each phase
- **Questions?** Each lab has FAQ section
- **Issues?** Common problems and solutions documented

---

**Ready to become a GCP Authentication Expert?**  
**Start with Phase 1 → [labs/phase-1-adc/README.md](phase-1-adc/README.md)**