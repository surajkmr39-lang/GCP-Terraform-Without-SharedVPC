#!/bin/bash
# Development Environment Startup Script
# Enterprise-grade VM initialization for development workloads

set -euo pipefail

# Logging setup
exec > >(tee /var/log/startup-script.log)
exec 2>&1

echo "🚀 Starting Development Environment Setup - $(date)"

# Update system packages
echo "📦 Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install essential development tools
echo "🔧 Installing development tools..."
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    unzip \
    jq \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install Docker
echo "🐳 Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Configure Docker for non-root user
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker

# Install Google Cloud SDK
echo "☁️ Installing Google Cloud SDK..."
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
apt-get update -y
apt-get install -y google-cloud-sdk

# Install Terraform
echo "🏗️ Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update -y
apt-get install -y terraform

# Install Node.js (LTS)
echo "📦 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
apt-get install -y nodejs

# Install Python development tools
echo "🐍 Installing Python development tools..."
apt-get install -y python3-pip python3-venv python3-dev
pip3 install --upgrade pip

# Configure development environment
echo "⚙️ Configuring development environment..."

# Create development directory
mkdir -p /home/ubuntu/development
chown ubuntu:ubuntu /home/ubuntu/development

# Set up Git configuration template
cat > /home/ubuntu/.gitconfig-template << 'EOF'
[user]
    name = Your Name
    email = your.email@company.com
[core]
    editor = vim
[pull]
    rebase = false
[init]
    defaultBranch = main
EOF
chown ubuntu:ubuntu /home/ubuntu/.gitconfig-template

# Configure vim
cat > /home/ubuntu/.vimrc << 'EOF'
set number
set tabstop=2
set shiftwidth=2
set expandtab
syntax on
EOF
chown ubuntu:ubuntu /home/ubuntu/.vimrc

# Set up development aliases
cat >> /home/ubuntu/.bashrc << 'EOF'

# Development aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias tf='terraform'
alias k='kubectl'
alias d='docker'
alias dc='docker-compose'

# Development environment info
echo "🚀 Development Environment Ready!"
echo "📍 Environment: Development"
echo "🏗️ Terraform: $(terraform version --json | jq -r '.terraform_version')"
echo "🐳 Docker: $(docker --version)"
echo "☁️ gcloud: $(gcloud version --format='value(Google Cloud SDK)')"
echo "📦 Node.js: $(node --version)"
echo "🐍 Python: $(python3 --version)"
EOF

# Configure automatic security updates
echo "🔒 Configuring automatic security updates..."
apt-get install -y unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "false";' >> /etc/apt/apt.conf.d/50unattended-upgrades

# Set up log rotation
echo "📝 Configuring log rotation..."
cat > /etc/logrotate.d/startup-script << 'EOF'
/var/log/startup-script.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
}
EOF

# Configure firewall (basic)
echo "🛡️ Configuring basic firewall..."
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp

# Install monitoring agent
echo "📊 Installing monitoring agent..."
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install

# Create development welcome message
cat > /etc/motd << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                          🚀 DEVELOPMENT ENVIRONMENT                          ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Environment: Development                                                    ║
║  Purpose:     Development and testing workloads                             ║
║  Network:     10.10.0.0/16                                                  ║
║  Machine:     e2-medium (2 vCPUs, 4GB RAM)                                  ║
║                                                                              ║
║  🔧 Tools Available:                                                         ║
║    • Docker & Docker Compose                                                ║
║    • Terraform                                                              ║
║    • Google Cloud SDK                                                       ║
║    • Node.js (LTS)                                                          ║
║    • Python 3 with pip                                                      ║
║    • Git, vim, htop, jq                                                     ║
║                                                                              ║
║  📚 Documentation: /home/ubuntu/development/                                ║
║  📝 Logs: /var/log/startup-script.log                                       ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF

# Final system cleanup
echo "🧹 Performing final cleanup..."
apt-get autoremove -y
apt-get autoclean

# Set completion marker
touch /var/log/startup-complete
echo "✅ Development Environment Setup Complete - $(date)"
echo "🎯 Ready for development workloads!"

# Send completion notification to Cloud Logging
gcloud logging write startup-script "Development environment setup completed successfully" --severity=INFO

exit 0