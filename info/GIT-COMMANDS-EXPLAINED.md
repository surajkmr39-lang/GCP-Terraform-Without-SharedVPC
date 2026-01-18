# 📝 Git Commands Explained

## 🎯 **Understanding Git Command Chains**

Git commands can be chained together for efficient workflows. Here's how to understand and use complex Git operations.

## 🔗 **Command Chaining Basics**

### **Operators:**
- `&&` - Execute next command only if previous succeeds
- `||` - Execute next command only if previous fails  
- `;` - Execute commands sequentially regardless of success/failure
- `|` - Pipe output from one command to another

### **Examples:**
```bash
# Chain with && (all must succeed)
git add . && git commit -m "Update" && git push

# Chain with || (fallback on failure)
git pull || git fetch

# Chain with ; (always execute)
git status; git log --oneline -5

# Pipe output
git log --oneline | head -10
```

## 🚀 **Common Git Workflows**

### **1. Complete Update Workflow:**
```bash
git add . && git commit -m "feat: add new feature" && git push origin main
```
**Explanation:**
- `git add .` - Stage all changes
- `&&` - Only continue if staging succeeds
- `git commit -m "..."` - Commit with message
- `&&` - Only continue if commit succeeds  
- `git push origin main` - Push to remote main branch

### **2. Safe Pull with Backup:**
```bash
git stash && git pull origin main && git stash pop
```
**Explanation:**
- `git stash` - Save current changes temporarily
- `&&` - Only continue if stash succeeds
- `git pull origin main` - Pull latest changes
- `&&` - Only continue if pull succeeds
- `git stash pop` - Restore stashed changes

### **3. Branch Creation and Switch:**
```bash
git checkout -b feature/new-feature && git push -u origin feature/new-feature
```
**Explanation:**
- `git checkout -b feature/new-feature` - Create and switch to new branch
- `&&` - Only continue if branch creation succeeds
- `git push -u origin feature/new-feature` - Push branch and set upstream

### **4. Cleanup and Reset:**
```bash
git fetch --prune && git branch -d $(git branch --merged | grep -v main)
```
**Explanation:**
- `git fetch --prune` - Update remote references and remove deleted branches
- `&&` - Only continue if fetch succeeds
- `git branch -d $(...)` - Delete merged branches (except main)

## 📊 **Project-Specific Git Workflows**

### **Infrastructure Updates:**
```bash
# Complete infrastructure update
git add environments/ modules/ && \
git commit -m "🏗️ Update multi-environment infrastructure" && \
git push origin main
```

### **Documentation Updates:**
```bash
# Update documentation
git add README.md info/ docs/ && \
git commit -m "📚 Update documentation and guides" && \
git push origin main
```

### **Feature Development:**
```bash
# Start new feature
git checkout main && \
git pull origin main && \
git checkout -b feature/workload-identity && \
git push -u origin feature/workload-identity
```

### **Release Preparation:**
```bash
# Prepare release
git checkout main && \
git pull origin main && \
git tag -a v1.0.0 -m "Release version 1.0.0" && \
git push origin v1.0.0
```

## 🔍 **Advanced Git Operations**

### **Interactive Rebase:**
```bash
# Clean up commit history
git rebase -i HEAD~3 && git push --force-with-lease origin feature-branch
```

### **Cherry-pick with Conflict Resolution:**
```bash
# Cherry-pick specific commit
git cherry-pick abc123 || git status && git add . && git cherry-pick --continue
```

### **Submodule Operations:**
```bash
# Update all submodules
git submodule update --init --recursive && git submodule foreach git pull origin main
```

## 🛠️ **Troubleshooting Git Issues**

### **Merge Conflicts:**
```bash
# Resolve merge conflicts
git pull origin main || (git status && echo "Resolve conflicts manually")
```

### **Undo Last Commit:**
```bash
# Undo last commit but keep changes
git reset --soft HEAD~1 && git status
```

### **Force Push Safely:**
```bash
# Safe force push
git push --force-with-lease origin feature-branch || git pull --rebase origin feature-branch
```

## 📈 **Git Hooks and Automation**

### **Pre-commit Hook:**
```bash
#!/bin/sh
# .git/hooks/pre-commit
terraform fmt -check=true -diff=true && \
terraform validate && \
echo "✅ Pre-commit checks passed"
```

### **Post-commit Hook:**
```bash
#!/bin/sh
# .git/hooks/post-commit
git log -1 --pretty=format:"✅ Committed: %s (%h)" && \
echo "\n🚀 Ready to push!"
```

## 🎯 **Best Practices**

### **Commit Message Conventions:**
```bash
# Conventional commits
git commit -m "feat: add workload identity federation"
git commit -m "fix: resolve terraform state lock issue"  
git commit -m "docs: update README with enterprise setup"
git commit -m "refactor: reorganize module structure"
```

### **Branch Naming:**
```bash
# Descriptive branch names
git checkout -b feature/multi-environment-setup
git checkout -b bugfix/state-lock-timeout
git checkout -b hotfix/security-vulnerability
git checkout -b docs/interview-preparation
```

### **Safe Operations:**
```bash
# Always check status first
git status && git add . && git commit -m "Update" && git push

# Verify before force operations
git log --oneline -5 && git push --force-with-lease origin main

# Backup before major changes
git branch backup-$(date +%Y%m%d) && git reset --hard HEAD~5
```

## 🔄 **Git Workflow Patterns**

### **GitFlow Pattern:**
```bash
# Start feature
git checkout develop && git pull origin develop && git checkout -b feature/new-feature

# Finish feature  
git checkout develop && git merge --no-ff feature/new-feature && git push origin develop

# Release
git checkout -b release/1.0.0 develop && git checkout main && git merge --no-ff release/1.0.0
```

### **GitHub Flow Pattern:**
```bash
# Simple feature workflow
git checkout main && git pull origin main && git checkout -b feature-branch
# ... make changes ...
git add . && git commit -m "Add feature" && git push origin feature-branch
# ... create pull request ...
git checkout main && git pull origin main && git branch -d feature-branch
```

## 📊 **Git Statistics and Analysis**

### **Repository Statistics:**
```bash
# Commit statistics
git log --oneline | wc -l && git log --pretty=format:"%an" | sort | uniq -c | sort -nr

# File change statistics
git log --stat --oneline | head -20

# Branch information
git branch -a && git remote -v
```

### **Code Analysis:**
```bash
# Find large files
git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | grep '^blob' | sort -nr -k3 | head -10

# Commit frequency
git log --pretty=format:"%ad" --date=short | sort | uniq -c | sort -nr
```

## 🎪 **Demo Commands for Interviews**

### **Show Project History:**
```bash
# Project evolution
git log --oneline --graph --decorate --all | head -20

# Recent changes
git log --since="1 week ago" --pretty=format:"%h %an %s" --graph

# File-specific history
git log --follow --patch -- README.md
```

### **Demonstrate Git Skills:**
```bash
# Show understanding of branching
git branch -a && git log --oneline --graph --decorate

# Show clean commit history
git log --oneline -10 && git show --stat HEAD

# Show collaboration skills
git log --pretty=format:"%h %an %ad %s" --date=relative -10
```

## 🏆 **Interview Questions & Answers**

### **Q: "Explain this Git command: `git add . && git commit -m 'Update' && git push`"**
**A:** "This is a chained command using the && operator. First, `git add .` stages all changes in the current directory. The && ensures the next command only runs if staging succeeds. Then `git commit -m 'Update'` creates a commit with the message 'Update'. Finally, if the commit succeeds, `git push` uploads the changes to the remote repository. The && operators ensure each step must succeed before proceeding."

### **Q: "How do you handle merge conflicts in a team environment?"**
**A:** "I use a systematic approach: first `git status` to see conflicted files, then manually resolve conflicts by editing the files and removing conflict markers. After resolving, I use `git add .` to stage the resolved files, then `git commit` to complete the merge. I always test the code after resolving conflicts and communicate with team members about the resolution."

### **Q: "What's the difference between `git merge` and `git rebase`?"**
**A:** "Git merge creates a merge commit that combines two branches, preserving the branch history. Git rebase replays commits from one branch onto another, creating a linear history. I use merge for feature integration to preserve context, and rebase for cleaning up feature branches before merging to maintain a clean main branch history."

This comprehensive understanding of Git commands demonstrates professional development workflow knowledge! 📝