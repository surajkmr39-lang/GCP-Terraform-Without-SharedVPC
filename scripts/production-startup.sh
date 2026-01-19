#!/bin/bash
# Production Environment Startup Script
# Enterprise-grade VM initialization for production workloads

set -euo pipefail

# Logging setup
exec > >(tee /var/log/startup-script.log)
exec 2>&1

echo "🚀 Starting Production Environment Setup - $(date)"

# Update system packages
echo "📦 Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install essential production tools
echo "🔧 Installing production tools..."
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
    ufw \
    logrotate \
    rsyslog \
    chrony \
    aide

# Install Docker
echo "🐳 Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Configure Docker for production
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker

# Configure Docker daemon for production
cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true
}
EOF
systemctl restart docker

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

# Install Python production tools
echo "🐍 Installing Python production tools..."
apt-get install -y python3-pip python3-venv python3-dev
pip3 install --upgrade pip

# Configure production environment
echo "⚙️ Configuring production environment..."

# Create production directory
mkdir -p /home/ubuntu/production
chown ubuntu:ubuntu /home/ubuntu/production

# Configure production-grade security
echo "🔒 Configuring production-grade security..."

# Configure fail2ban with strict rules
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF

systemctl enable fail2ban
systemctl restart fail2ban

# Configure strict firewall
ufw --force reset
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow from 203.0.113.0/24 to any port 22  # Office network only
ufw allow from 198.51.100.0/24 to any port 22  # VPN network only
ufw allow 80/tcp
ufw allow 443/tcp

# Configure automatic security updates
apt-get install -y unattended-upgrades
cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
EOF

# Configure comprehensive log rotation
cat > /etc/logrotate.d/production-logs << 'EOF'
/var/log/startup-script.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}

/var/log/application/*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 644 ubuntu ubuntu
    postrotate
        systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}
EOF

# Create application log directory
mkdir -p /var/log/application
chown ubuntu:ubuntu /var/log/application

# Configure time synchronization
systemctl enable chrony
systemctl start chrony

# Install and configure monitoring agent
echo "📊 Installing monitoring agent..."
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install

# Configure production-specific settings
cat >> /home/ubuntu/.bashrc << 'EOF'

# Production environment aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias tf='terraform'
alias k='kubectl'
alias d='docker'
alias dc='docker-compose'

# Production environment info
echo "🏭 Production Environment Ready!"
echo "📍 Environment: Production"
echo "🏗️ Terraform: $(terraform version --json | jq -r '.terraform_version')"
echo "🐳 Docker: $(docker --version)"
echo "☁️ gcloud: $(gcloud version --format='value(Google Cloud SDK)')"
echo "📦 Node.js: $(node --version)"
echo "🐍 Python: $(python3 --version)"
echo "🔒 Security: Production-grade (fail2ban, strict firewall, auto-updates)"
EOF

# Configure system limits for production
cat >> /etc/security/limits.conf << 'EOF'
# Production system limits
ubuntu soft nofile 65536
ubuntu hard nofile 65536
ubuntu soft nproc 32768
ubuntu hard nproc 32768
EOF

# Configure kernel parameters for production
cat >> /etc/sysctl.conf << 'EOF'
# Production kernel parameters
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 10
vm.swappiness = 10
EOF
sysctl -p

# Create production welcome message
cat > /etc/motd << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                          🏭 PRODUCTION ENVIRONMENT                           ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Environment: Production                                                     ║
║  Purpose:     Live production workloads                                     ║
║  Network:     10.30.0.0/16                                                  ║
║  Machine:     e2-standard-4 (4 vCPUs, 16GB RAM, 100GB SSD)                 ║
║                                                                              ║
║  🔧 Tools Available:                                                         ║
║    • Docker & Docker Compose (production config)                            ║
║    • Terraform                                                              ║
║    • Google Cloud SDK                                                       ║
║    • Node.js (LTS)                                                          ║
║    • Python 3 with pip                                                      ║
║    • Production monitoring & logging                                        ║
║                                                                              ║
║  🔒 Security: Production-grade                                               ║
║    • fail2ban with strict rules                                             ║
║    • Restrictive firewall (office/VPN only)                                 ║
║    • Automatic security updates                                             ║
║    • File integrity monitoring (AIDE)                                       ║
║    • Comprehensive logging & rotation                                       ║
║                                                                              ║
║  📚 Documentation: /home/ubuntu/production/                                 ║
║  📝 Logs: /var/log/startup-script.log, /var/log/application/                ║
║                                                                              ║
║  ⚠️  PRODUCTION SYSTEM - Handle with care!                                  ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF

# Initialize file integrity monitoring
echo "🛡️ Initializing file integrity monitoring..."
aide --init
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Create production health check script
cat > /home/ubuntu/production/health-check.sh << 'EOF'
#!/bin/bash
# Production health check script

echo "🏭 Production System Health Check - $(date)"
echo "=============================================="

# System resources
echo "💻 System Resources:"
echo "  CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "  Memory Usage: $(free | grep Mem | awk '{printf("%.1f%%", $3/$2 * 100.0)}')"
echo "  Disk Usage: $(df -h / | awk 'NR==2{printf "%s", $5}')"

# Services status
echo ""
echo "🔧 Critical Services:"
echo "  Docker: $(systemctl is-active docker)"
echo "  fail2ban: $(systemctl is-active fail2ban)"
echo "  UFW: $(systemctl is-active ufw)"
echo "  Chrony: $(systemctl is-active chrony)"
echo "  Google Cloud Ops Agent: $(systemctl is-active google-cloud-ops-agent)"

# Network connectivity
echo ""
echo "🌐 Network Connectivity:"
echo "  Google DNS: $(ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo "OK" || echo "FAIL")"
echo "  GCP Metadata: $(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name >/dev/null 2>&1 && echo "OK" || echo "FAIL")"

echo ""
echo "✅ Health check completed"
EOF

chmod +x /home/ubuntu/production/health-check.sh
chown ubuntu:ubuntu /home/ubuntu/production/health-check.sh

# Final system cleanup
echo "🧹 Performing final cleanup..."
apt-get autoremove -y
apt-get autoclean

# Set completion marker
touch /var/log/startup-complete
echo "✅ Production Environment Setup Complete - $(date)"
echo "🏭 Ready for production workloads!"

# Send completion notification to Cloud Logging
gcloud logging write startup-script "Production environment setup completed successfully" --severity=INFO

# Run initial health check
echo "🔍 Running initial health check..."
/home/ubuntu/production/health-check.sh

exit 0