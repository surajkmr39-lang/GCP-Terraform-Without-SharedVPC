#!/bin/bash
# Staging Environment Startup Script
# Enterprise-grade VM initialization for staging workloads

set -euo pipefail

# Logging setup
exec > >(tee /var/log/startup-script.log)
exec 2>&1

echo "🚀 Starting Staging Environment Setup - $(date)"

# Update system packages
echo "📦 Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install essential tools
echo "🔧 Installing essential tools..."
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
    lsb-release \
    fail2ban \
    ufw

# Install Docker
echo "🐳 Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Configure Docker
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

# Configure staging environment
echo "⚙️ Configuring staging environment..."

# Create staging directory
mkdir -p /home/ubuntu/staging
chown ubuntu:ubuntu /home/ubuntu/staging

# Configure enhanced security for staging
echo "🔒 Configuring enhanced security..."

# Configure fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Configure firewall
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8080/tcp  # Application port

# Configure automatic security updates
apt-get install -y unattended-upgrades
echo 'Unattended-Upgrade::Automatic-Reboot "false";' >> /etc/apt/apt.conf.d/50unattended-upgrades

# Set up log rotation
cat > /etc/logrotate.d/startup-script << 'EOF'
/var/log/startup-script.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
}
EOF

# Install monitoring agent
echo "📊 Installing monitoring agent..."
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install

# Configure staging-specific settings
cat >> /home/ubuntu/.bashrc << 'EOF'

# Staging environment aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias tf='terraform'
alias k='kubectl'
alias d='docker'
alias dc='docker-compose'

# Staging environment info
echo "🎭 Staging Environment Ready!"
echo "📍 Environment: Staging"
echo "🏗️ Terraform: $(terraform version --json | jq -r '.terraform_version')"
echo "🐳 Docker: $(docker --version)"
echo "☁️ gcloud: $(gcloud version --format='value(Google Cloud SDK)')"
echo "📦 Node.js: $(node --version)"
echo "🐍 Python: $(python3 --version)"
EOF

# Create staging welcome message
cat > /etc/motd << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                            🎭 STAGING ENVIRONMENT                            ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Environment: Staging                                                        ║
║  Purpose:     Pre-production testing and validation                         ║
║  Network:     10.20.0.0/16                                                  ║
║  Machine:     e2-standard-2 (2 vCPUs, 8GB RAM)                              ║
║                                                                              ║
║  🔧 Tools Available:                                                         ║
║    • Docker & Docker Compose                                                ║
║    • Terraform                                                              ║
║    • Google Cloud SDK                                                       ║
║    • Node.js (LTS)                                                          ║
║    • Python 3 with pip                                                      ║
║    • Enhanced security (fail2ban, ufw)                                      ║
║                                                                              ║
║  🔒 Security: Enhanced (fail2ban, firewall, auto-updates)                   ║
║  📚 Documentation: /home/ubuntu/staging/                                    ║
║  📝 Logs: /var/log/startup-script.log                                       ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF

# Final system cleanup
echo "🧹 Performing final cleanup..."
apt-get autoremove -y
apt-get autoclean

# Set completion marker
touch /var/log/startup-complete
echo "✅ Staging Environment Setup Complete - $(date)"
echo "🎯 Ready for pre-production testing!"

# Send completion notification to Cloud Logging
gcloud logging write startup-script "Staging environment setup completed successfully" --severity=INFO

exit 0