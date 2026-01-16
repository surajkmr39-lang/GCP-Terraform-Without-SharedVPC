# 🎨 Install Architecture Diagram Tools

## Quick Installation

### Step 1: Install Python Package

```bash
# Make sure you're in your virtual environment
.venv\Scripts\activate

# Install diagrams library
pip install diagrams
```

### Step 2: Install Graphviz

**Option A: Using Chocolatey (Recommended)**
```bash
choco install graphviz
```

**Option B: Manual Download**
1. Download from: https://graphviz.org/download/
2. Install to: `C:\Program Files\Graphviz`
3. Add to PATH: `C:\Program Files\Graphviz\bin`

### Step 3: Verify Installation

```bash
# Test diagrams
python -c "import diagrams; print('✅ Diagrams installed')"

# Test graphviz
dot -V
```

## Generate Diagrams

Once installed, run:

```bash
python generate-architecture-diagram.py
```

This creates:
- `gcp-infrastructure-architecture.png`
- `gcp-network-architecture.png`
- `cicd-pipeline-flow.png`

## Alternative: Use Online Tools

If you prefer not to install locally, use these online tools:

### 1. Draw.io (diagrams.net)
- URL: https://app.diagrams.net/
- Free, no installation
- Export as PNG/PDF

### 2. Lucidchart
- URL: https://www.lucidchart.com/
- Free tier available
- Professional templates

### 3. CloudCraft (for AWS/GCP)
- URL: https://www.cloudcraft.co/
- GCP support
- 3D diagrams

## Manual Diagram Creation

If you want to create diagrams manually, here's the structure:

```
┌─────────────────────────────────────────────────────────┐
│                  GitHub Repository                      │
│                 surajkmr39-lang/GCP-Terraform          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              GitHub Actions CI/CD Pipeline              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │ Validate │→ │ Security │→ │   Plan   │→ │ Apply  │ │
│  └──────────┘  └──────────┘  └──────────┘  └────────┘ │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│        Workload Identity Federation (WIF)               │
│        Keyless Authentication - No Stored Keys          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              GCP Infrastructure                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  VPC: dev-vpc (10.0.1.0/24)                      │  │
│  │  ├── Cloud Router                                │  │
│  │  ├── Cloud NAT                                   │  │
│  │  ├── Firewall Rules (SSH, HTTP/HTTPS)           │  │
│  │  └── VM Instance: dev-vm (e2-medium)            │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Issue: "Module not found"
```bash
pip install diagrams
```

### Issue: "Graphviz not found"
```bash
# Install graphviz
choco install graphviz

# Or download from: https://graphviz.org/download/
```

### Issue: "Permission denied"
```bash
# Run PowerShell as Administrator
```

## Next Steps

1. Install the tools (optional)
2. Generate diagrams (optional)
3. Or use the text-based diagrams in documentation
4. Or create diagrams using online tools

**The architecture diagram generator is now available in your project!**

File: `generate-architecture-diagram.py`