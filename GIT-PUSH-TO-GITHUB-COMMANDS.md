# 🚀 Git Commands to Push Project to GitHub

## Prerequisites
- Create a new repository on GitHub (e.g., `gcp-terraform-infrastructure`)
- Have Git installed locally
- Have GitHub CLI installed (optional but recommended)

---

## 📋 Step-by-Step Git Commands

### Step 1: Initialize Git Repository (if not already done)
```bash
# Check if git is already initialized
git status

# If not initialized, run:
git init
```

### Step 2: Add All Files to Git
```bash
# Add all files to staging
git add .

# Check what files are staged
git status
```

### Step 3: Create Initial Commit
```bash
# Create initial commit
git commit -m "Initial commit: Complete GCP Terraform Infrastructure Project

- Multi-environment setup (dev/staging/prod)
- Workload Identity Federation configuration
- GitHub Actions CI/CD pipeline
- Comprehensive documentation and guides
- Terraform modules for network, compute, security, IAM
- Architecture diagrams and learning materials"
```

### Step 4: Add Remote Repository
```bash
# Replace YOUR_USERNAME and YOUR_REPO_NAME with actual values
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Verify remote is added
git remote -v
```

### Step 5: Push to GitHub
```bash
# Push to main branch
git branch -M main
git push -u origin main
```

---

## 🔄 Alternative: Using GitHub CLI (Recommended)

If you have GitHub CLI installed, you can create and push in one go:

```bash
# Login to GitHub CLI (if not already logged in)
gh auth login

# Create repository and push
gh repo create gcp-terraform-infrastructure --public --source=. --remote=origin --push

# Or for private repository
gh repo create gcp-terraform-infrastructure --private --source=. --remote=origin --push
```

---

## 🛠️ Additional Useful Commands

### Create .gitignore (if needed)
```bash
# Create .gitignore file
cat > .gitignore << 'EOF'
# Terraform
*.tfstate
*.tfstate.*
*.tfvars
.terraform/
.terraform.lock.hcl
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Python
__pycache__/
*.py[cod]
*$py.class
.venv/
venv/

# Logs
*.log
logs/

# Temporary files
*.tmp
*.temp
EOF

# Add and commit .gitignore
git add .gitignore
git commit -m "Add .gitignore for Terraform and common files"
```

### Set Up Branch Protection (Optional)
```bash
# Create develop branch
git checkout -b develop
git push -u origin develop

# Switch back to main
git checkout main
```

### Add Repository Topics/Tags
```bash
# Add topics to repository (using GitHub CLI)
gh repo edit --add-topic terraform
gh repo edit --add-topic gcp
gh repo edit --add-topic infrastructure-as-code
gh repo edit --add-topic devops
gh repo edit --add-topic github-actions
gh repo edit --add-topic workload-identity-federation
```

---

## 📊 Verify Upload Success

After pushing, verify everything is uploaded:

```bash
# Check repository status
git status

# View commit history
git log --oneline

# Check remote repository
gh repo view --web
# Or visit: https://github.com/YOUR_USERNAME/YOUR_REPO_NAME
```

---

## 🔧 Troubleshooting Common Issues

### Issue 1: Authentication Error
```bash
# If using HTTPS and getting auth errors, use token
git remote set-url origin https://YOUR_TOKEN@github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Or switch to SSH
git remote set-url origin git@github.com:YOUR_USERNAME/YOUR_REPO_NAME.git
```

### Issue 2: Large File Warning
```bash
# If you get warnings about large files, check file sizes
find . -type f -size +50M

# Remove large files from git if needed
git rm --cached path/to/large/file
git commit -m "Remove large file"
```

### Issue 3: Repository Already Exists
```bash
# If repository exists and you want to force push
git push -f origin main

# Or pull first then push
git pull origin main --allow-unrelated-histories
git push origin main
```

---

## 📋 Final Checklist

After running the commands, verify:

- [ ] Repository is created on GitHub
- [ ] All files are uploaded
- [ ] README.md displays properly
- [ ] Documentation files are readable
- [ ] CI/CD workflows are visible in Actions tab
- [ ] Repository has appropriate topics/tags
- [ ] Branch protection rules are set (if needed)

---

## 🎯 Next Steps After Upload

1. **Update Repository Settings**:
   - Add description
   - Set up branch protection rules
   - Configure GitHub Pages (if needed)

2. **Update Documentation**:
   - Update any hardcoded paths in documentation
   - Add repository-specific badges
   - Update CI/CD configuration if needed

3. **Set Up Secrets** (for CI/CD):
   - Add GCP project ID
   - Configure Workload Identity Federation
   - Add any required environment variables

---

*Run these commands in your project root directory where all your Terraform files are located.*