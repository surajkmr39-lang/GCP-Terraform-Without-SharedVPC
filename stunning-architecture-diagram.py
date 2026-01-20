#!/usr/bin/env python3
"""
Stunning Modern GCP Terraform Architecture Diagram
Creates a beautiful, modern architecture diagram with gradients and professional styling
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.gcp.compute import ComputeEngine
from diagrams.gcp.network import VPC
from diagrams.gcp.security import Iam, SecurityCommandCenter
from diagrams.gcp.storage import GCS
from diagrams.gcp.devtools import SourceRepositories
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.client import Users
from diagrams.onprem.iac import Terraform

# Custom styling for modern look
graph_attr = {
    "fontsize": "16",
    "fontname": "Arial Bold",
    "bgcolor": "transparent",
    "dpi": "300",
    "pad": "1.0",
    "splines": "curved",
    "concentrate": "true",
    "rankdir": "TB",
    "nodesep": "1.5",
    "ranksep": "2.0"
}

node_attr = {
    "fontsize": "12",
    "fontname": "Arial",
    "style": "filled,rounded",
    "fillcolor": "white",
    "color": "#2196F3",
    "penwidth": "2"
}

edge_attr = {
    "fontsize": "10",
    "fontname": "Arial",
    "color": "#1976D2",
    "penwidth": "2",
    "arrowsize": "1.2"
}

with Diagram(
    "🚀 Enterprise GCP Terraform Infrastructure",
    filename="stunning-architecture",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
    node_attr=node_attr,
    edge_attr=edge_attr
):
    
    # Developer and CI/CD Layer
    with Cluster("👨‍💻 Development & CI/CD", graph_attr={"bgcolor": "#E3F2FD", "style": "rounded,filled"}):
        developer = Users("Developer")
        github = SourceRepositories("GitHub Repository")
        github_actions = GithubActions("GitHub Actions\n(WIF Authentication)")
        terraform_cli = Terraform("Terraform CLI")
    
    # Shared Infrastructure Layer
    with Cluster("🔐 Shared Infrastructure", graph_attr={"bgcolor": "#F3E5F5", "style": "rounded,filled"}):
        wif_pool = Iam("Workload Identity Pool\n(github-pool)")
        wif_provider = Iam("WIF Provider\n(github)")
        service_account = Iam("Service Account\n(galaxy@praxis-gear)")
        gcs_state = GCS("Terraform State\n(Remote Backend)")
    
    # Multi-Environment Infrastructure
    environments = []
    env_configs = [
        ("Development", "#E8F5E8", "10.10.0.0/16", "34.59.39.203"),
        ("Staging", "#FFF3E0", "10.20.0.0/16", "Pending"),
        ("Production", "#FFEBEE", "10.30.0.0/16", "Ready")
    ]
    
    for env_name, bg_color, cidr, status in env_configs:
        with Cluster(f"🌐 {env_name} Environment", graph_attr={"bgcolor": bg_color, "style": "rounded,filled"}):
            vpc = VPC(f"{env_name.lower()}-vpc\n({cidr})")
            security = SecurityCommandCenter(f"Security Rules\nSSH: Corporate Only")
            vm = ComputeEngine(f"{env_name.lower()}-vm\n({status})")
            
            vpc >> Edge(label="protects", style="dashed") >> security
            security >> Edge(label="allows", color="#4CAF50") >> vm
            environments.append((vpc, vm))
    
    # Connections with beautiful styling
    developer >> Edge(label="💻 commits", color="#FF9800", style="bold") >> github
    github >> Edge(label="🔄 triggers", color="#2196F3", style="bold") >> github_actions
    
    github_actions >> Edge(label="🔑 authenticates", color="#9C27B0", style="bold") >> wif_pool
    wif_pool >> Edge(label="🎭 impersonates", color="#9C27B0") >> service_account
    
    terraform_cli >> Edge(label="📊 stores state", color="#FF5722", style="bold") >> gcs_state
    github_actions >> Edge(label="🚀 deploys", color="#4CAF50", style="bold") >> terraform_cli
    
    # Connect to all environments
    for i, (vpc, vm) in enumerate(environments):
        if i == 0:  # Development
            terraform_cli >> Edge(label="🏗️ provisions", color="#4CAF50") >> vpc
        else:
            terraform_cli >> Edge(style="dashed", color="#757575") >> vpc

print("✨ Stunning architecture diagram generated successfully!")
print("📁 Files created:")
print("   • stunning-architecture.png (High-resolution image)")
print("   • stunning-architecture.pdf (Presentation ready)")
print("   • stunning-architecture.svg (Scalable vector)")