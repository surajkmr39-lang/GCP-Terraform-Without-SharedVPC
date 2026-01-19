#!/usr/bin/env python3
"""
Simple GCP Architecture Diagram Generator
Clean, professional diagram for the project
"""

def create_simple_diagram():
    """Create a simple text-based architecture diagram"""
    
    diagram = """
GCP Terraform Infrastructure Architecture

Project: praxis-gear-483220-k4
|-- Shared WIF Infrastructure (Persistent)
|   |-- github-actions-pool (WIF Pool)
|   |-- github-actions (WIF Provider)
|   `-- github-actions-sa (Service Account)
|
|-- Development Environment (DEPLOYED)
|   |-- development-vpc (10.10.0.0/16)
|   |-- development-vm (e2-medium, 34.59.39.203)
|   `-- Complete security & networking stack
|
|-- Staging Environment (READY)
|   |-- staging-vpc (10.20.0.0/16)
|   |-- staging-vm (e2-standard-2, us-central1-c)
|   `-- Complete security & networking stack
|
`-- Production Environment (READY)
    |-- production-vpc (10.30.0.0/16)
    |-- production-vm (e2-standard-4, us-central1-b)
    `-- Complete security & networking stack

CI/CD Flow:
GitHub Actions -> WIF Authentication -> Environment Deployment

Security:
- Individual VPC per environment (complete isolation)
- Shared WIF for consistent authentication
- Private SSH access only
- Enterprise naming conventions
"""
    
    return diagram

def main():
    """Generate and display the architecture diagram"""
    # Avoid UnicodeEncodeError on some Windows consoles by keeping output ASCII-only
    print("GCP Terraform Architecture")
    print("=" * 50)
    print(create_simple_diagram())
    print("=" * 50)
    print("Architecture overview complete!")

if __name__ == "__main__":
    main()