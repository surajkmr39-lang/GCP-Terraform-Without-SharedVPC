#!/usr/bin/env python3
"""
GCP Terraform Architecture Diagram Generator
Generates a visual diagram of the GCP infrastructure
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.gcp.compute import ComputeEngine
from diagrams.gcp.network import VPC, FirewallRules, Router, NAT
from diagrams.gcp.security import Iam
from diagrams.gcp.devtools import GCR
from diagrams.onprem.vcs import Github
from diagrams.onprem.ci import GithubActions

# Diagram configuration
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "pad": "0.5",
}

with Diagram(
    "GCP Terraform Infrastructure with CI/CD",
    filename="gcp-infrastructure-architecture",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
):
    
    # GitHub and CI/CD
    with Cluster("GitHub Repository"):
        github = Github("GCP-Terraform\nRepository")
        github_actions = GithubActions("GitHub Actions\nCI/CD Pipeline")
        github >> Edge(label="triggers") >> github_actions
    
    # Workload Identity Federation
    with Cluster("Authentication"):
        wif = Iam("Workload Identity\nFederation")
        service_account = Iam("Service Account\ngalaxy@...")
        
        github_actions >> Edge(label="OIDC token", color="blue") >> wif
        wif >> Edge(label="temporary token", color="green") >> service_account
    
    # GCP Infrastructure
    with Cluster("GCP Project: praxis-gear-483220-k4"):
        
        # Network Layer
        with Cluster("Network Layer"):
            vpc = VPC("dev-vpc\n10.0.1.0/24")
            router = Router("Cloud Router")
            nat = NAT("Cloud NAT")
            firewall = FirewallRules("Firewall Rules\nSSH, HTTP/HTTPS")
            
            vpc >> router >> nat
            vpc >> firewall
        
        # Compute Layer
        with Cluster("Compute Layer"):
            vm = ComputeEngine("dev-vm\ne2-medium\nUbuntu 22.04")
            
        # Connections
        service_account >> Edge(label="deploys", color="orange") >> vpc
        vpc >> vm
        firewall >> vm

# Generate network-only diagram
with Diagram(
    "GCP Network Architecture",
    filename="gcp-network-architecture",
    show=False,
    direction="LR",
    graph_attr=graph_attr,
):
    
    with Cluster("Internet"):
        internet = GCR("Internet")
    
    with Cluster("GCP VPC: dev-vpc"):
        with Cluster("Public"):
            router = Router("Cloud Router")
            nat = NAT("Cloud NAT\nOutbound Only")
            firewall = FirewallRules("Firewall\nSSH: 22\nHTTP: 80/443")
        
        with Cluster("Private Subnet: 10.0.1.0/24"):
            vm = ComputeEngine("dev-vm\n10.0.1.2\nPrivate IP")
    
    internet >> Edge(label="inbound", color="red") >> firewall >> vm
    vm >> Edge(label="outbound", color="green") >> nat >> router >> internet

# Generate CI/CD flow diagram
with Diagram(
    "CI/CD Pipeline Flow",
    filename="cicd-pipeline-flow",
    show=False,
    direction="TB",
    graph_attr=graph_attr,
):
    
    # Developer workflow
    with Cluster("Developer Workflow"):
        github_repo = Github("Push Code")
    
    # CI/CD Pipeline
    with Cluster("GitHub Actions Pipeline"):
        validate = GithubActions("Validate &\nLint")
        security = GithubActions("Security\nScan")
        plan = GithubActions("Terraform\nPlan")
        apply = GithubActions("Terraform\nApply")
        
        github_repo >> validate >> security >> plan >> apply
    
    # Authentication
    with Cluster("Authentication"):
        wif_auth = Iam("WIF\nKeyless Auth")
        apply >> Edge(label="authenticate", color="blue") >> wif_auth
    
    # GCP Infrastructure
    with Cluster("GCP Infrastructure"):
        infrastructure = ComputeEngine("Deploy\nInfrastructure")
        wif_auth >> Edge(label="deploy", color="green") >> infrastructure

print("✅ Architecture diagrams generated successfully!")
print("📊 Generated files:")
print("   - gcp-infrastructure-architecture.png")
print("   - gcp-network-architecture.png")
print("   - cicd-pipeline-flow.png")
print("\n💡 To view: Open the PNG files in your project directory")
