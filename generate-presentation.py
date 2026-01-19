"""
Generate comprehensive HTML presentation website with embedded architecture diagram.
Creates a professional multi-tab presentation for screen sharing.
"""

import json
import webbrowser
from pathlib import Path

import plotly.graph_objects as go

OUTPUT_FILE = Path("architecture-presentation.html")


def build_diagram_figure() -> go.Figure:
    """Build the architecture diagram figure."""
    nodes = [
        {"id": "repo", "label": "GitHub Repo", "x": 12, "y": 86, "group": "github",
         "hover": "<b>GitHub Repository</b><br>surajkmr39-lang/GCP-Terraform"},
        {"id": "gha", "label": "GitHub Actions", "x": 33, "y": 86, "group": "github",
         "hover": "<b>CI/CD</b><br>Validation → Security Scan → Terraform Plan/Apply"},
        {"id": "wif", "label": "Shared WIF", "x": 58, "y": 86, "group": "wif",
         "hover": "<b>Workload Identity Federation</b><br>Pool: github-actions-pool<br>Provider: github-actions<br>Service Account: github-actions-sa"},
        {"id": "gcp", "label": "GCP Project", "x": 82, "y": 86, "group": "meta",
         "hover": "<b>GCP Project</b><br>praxis-gear-483220-k4"},
        {"id": "dev_vpc", "label": "Dev VPC", "x": 18, "y": 55, "group": "dev",
         "hover": "<b>Development VPC</b><br>development-vpc<br>CIDR: 10.10.0.0/16"},
        {"id": "dev_sec", "label": "Dev FW", "x": 8, "y": 45, "group": "dev",
         "hover": "<b>Security</b><br>Firewall rules: SSH / HTTP(S) / Internal / Health Checks"},
        {"id": "dev_iam", "label": "Dev IAM", "x": 18, "y": 45, "group": "dev",
         "hover": "<b>IAM</b><br>Service Account: development-vm-sa<br>Roles: compute.viewer, storage.objectViewer, logging.logWriter, monitoring.metricWriter"},
        {"id": "dev_vm", "label": "Dev VM", "x": 28, "y": 45, "group": "dev",
         "hover": "<b>Compute</b><br>development-vm<br>Machine: e2-medium<br>External IP: 34.59.39.203"},
        {"id": "stg_vpc", "label": "Staging VPC", "x": 50, "y": 55, "group": "staging",
         "hover": "<b>Staging VPC</b><br>staging-vpc<br>CIDR: 10.20.0.0/16"},
        {"id": "stg_sec", "label": "Staging FW", "x": 40, "y": 45, "group": "staging",
         "hover": "<b>Security</b><br>Firewall rules aligned to staging environment"},
        {"id": "stg_iam", "label": "Staging IAM", "x": 50, "y": 45, "group": "staging",
         "hover": "<b>IAM</b><br>Service Account: staging-vm-sa<br>WIF binding to shared pool"},
        {"id": "stg_vm", "label": "Staging VM", "x": 60, "y": 45, "group": "staging",
         "hover": "<b>Compute</b><br>staging-vm<br>Machine: e2-standard-2"},
        {"id": "prd_vpc", "label": "Prod VPC", "x": 82, "y": 55, "group": "prod",
         "hover": "<b>Production VPC</b><br>production-vpc<br>CIDR: 10.30.0.0/16"},
        {"id": "prd_sec", "label": "Prod FW", "x": 72, "y": 45, "group": "prod",
         "hover": "<b>Security</b><br>Firewall rules aligned to production environment"},
        {"id": "prd_iam", "label": "Prod IAM", "x": 82, "y": 45, "group": "prod",
         "hover": "<b>IAM</b><br>Service Account: production-vm-sa<br>WIF binding to shared pool"},
        {"id": "prd_vm", "label": "Prod VM", "x": 92, "y": 45, "group": "prod",
         "hover": "<b>Compute</b><br>production-vm<br>Machine: e2-standard-4"},
        {"id": "modules", "label": "Terraform Modules", "x": 50, "y": 18, "group": "meta",
         "hover": "<b>Modules</b><br><code>modules/network</code>: VPC, Subnet, Router, NAT, Flow Logs<br><code>modules/security</code>: Firewall rules<br><code>modules/iam</code>: env SAs + WIF binding<br><code>modules/compute</code>: Shielded VM, OS Login"},
        {"id": "state", "label": "GCS Remote State", "x": 80, "y": 18, "group": "meta",
         "hover": "<b>State</b><br>Backend: GCS bucket praxis-gear-483220-k4-terraform-state<br>Separate prefixes per environment + shared/wif"},
    ]

    edges = [
        ("repo", "gha", "push / PR"),
        ("gha", "wif", "OIDC token"),
        ("wif", "gcp", "impersonate SA"),
        ("gha", "gcp", "terraform plan/apply"),
        ("wif", "dev_iam", "shared auth"),
        ("wif", "stg_iam", "shared auth"),
        ("wif", "prd_iam", "shared auth"),
        ("dev_vpc", "dev_vm", "subnet routing"),
        ("dev_sec", "dev_vm", "tags: ssh/http/hc"),
        ("dev_iam", "dev_vm", "attach SA"),
        ("stg_vpc", "stg_vm", "subnet routing"),
        ("stg_sec", "stg_vm", "tags: ssh/http/hc"),
        ("stg_iam", "stg_vm", "attach SA"),
        ("prd_vpc", "prd_vm", "subnet routing"),
        ("prd_sec", "prd_vm", "tags: ssh/http/hc"),
        ("prd_iam", "prd_vm", "attach SA"),
        ("modules", "dev_vpc", "used by"),
        ("modules", "stg_vpc", "used by"),
        ("modules", "prd_vpc", "used by"),
        ("state", "dev_vpc", "env state"),
        ("state", "stg_vpc", "env state"),
        ("state", "prd_vpc", "env state"),
        ("state", "wif", "shared state"),
    ]

    group_colors = {
        "github": "#2d9cdb",
        "wif": "#f2994a",
        "dev": "#27ae60",
        "staging": "#f2c94c",
        "prod": "#eb5757",
        "meta": "#34495e",
    }

    nodes_by_id = {n["id"]: n for n in nodes}

    # Edges trace
    edge_xs = []
    edge_ys = []
    for src, dst, _ in edges:
        src_node = nodes_by_id[src]
        dst_node = nodes_by_id[dst]
        edge_xs += [src_node["x"], dst_node["x"], None]
        edge_ys += [src_node["y"], dst_node["y"], None]

    edge_trace = go.Scatter(
        x=edge_xs,
        y=edge_ys,
        mode="lines",
        line=dict(color="#7f8c8d", width=2),
        hoverinfo="none",
        showlegend=False,
    )

    # Nodes trace
    node_trace = go.Scatter(
        x=[n["x"] for n in nodes],
        y=[n["y"] for n in nodes],
        mode="markers+text",
        text=[n["label"] for n in nodes],
        textposition="bottom center",
        textfont=dict(size=13, color="#1b2631"),
        marker=dict(
            size=26,
            color=[group_colors[n["group"]] for n in nodes],
            line=dict(color="#ffffff", width=2),
        ),
        hovertext=[n["hover"] for n in nodes],
        hoverinfo="text",
        showlegend=False,
    )

    fig = go.Figure(data=[edge_trace, node_trace])

    # Add panels
    panels = [
        {"x0": 3, "y0": 76, "x1": 97, "y1": 97, "title": "CI/CD & Authentication", "fill": "#fbfcfc"},
        {"x0": 3, "y0": 32, "x1": 33, "y1": 74, "title": "Development (dev)", "fill": "#ecfdf3"},
        {"x0": 36, "y0": 32, "x1": 66, "y1": 74, "title": "Staging (staging)", "fill": "#fffaf0"},
        {"x0": 69, "y0": 32, "x1": 97, "y1": 74, "title": "Production (prod)", "fill": "#fff5f5"},
        {"x0": 3, "y0": 6, "x1": 97, "y1": 28, "title": "Terraform modules + state", "fill": "#fbfcfc"},
    ]

    for panel in panels:
        fig.add_shape(
            type="rect",
            x0=panel["x0"],
            y0=panel["y0"],
            x1=panel["x1"],
            y1=panel["y1"],
            line=dict(color="#d0d3d4", width=1.2),
            fillcolor=panel["fill"],
            opacity=1,
            layer="below",
        )
        fig.add_annotation(
            x=panel["x0"] + 1.0,
            y=panel["y1"] - 1.5,
            text=f"<b>{panel['title']}</b>",
            showarrow=False,
            xanchor="left",
            font=dict(size=13, color="#2c3e50"),
        )

    fig.update_layout(
        title=dict(
            text="GCP Terraform Architecture (Individual VPC per Environment + Shared WIF)",
            x=0.5,
            xanchor="center",
            font=dict(size=22),
        ),
        showlegend=False,
        xaxis=dict(visible=False, range=[0, 100], fixedrange=True),
        yaxis=dict(visible=False, range=[0, 100], fixedrange=True),
        margin=dict(l=24, r=24, t=80, b=24),
        plot_bgcolor="#ffffff",
        paper_bgcolor="#ffffff",
        hoverlabel=dict(bgcolor="#ffffff", font=dict(size=12)),
        height=700,
    )

    return fig


def generate_presentation_html() -> str:
    """Generate the full HTML presentation with embedded diagram."""
    fig = build_diagram_figure()
    
    # Generate diagram JSON data for embedding
    diagram_json = fig.to_json()
    
    # Read the base HTML template
    html_template = Path("architecture-presentation.html").read_text(encoding="utf-8")
    
    # Replace the placeholder comment with actual Plotly code
    marker = "// DIAGRAM_DATA_PLACEHOLDER"
    replacement = f"""const diagramData = {diagram_json};
            Plotly.newPlot('architecture-diagram', diagramData.data, diagramData.layout, diagramData.config);
            // Store for tab switching
            window.architectureDiagramData = diagramData;"""
    
    html_template = html_template.replace(marker, replacement)
    
    return html_template


def main():
    """Generate the presentation HTML file."""
    html_content = generate_presentation_html()
    OUTPUT_FILE.write_text(html_content, encoding="utf-8")
    print(f"[+] Presentation website written to: {OUTPUT_FILE.resolve()}")
    try:
        webbrowser.open(OUTPUT_FILE.resolve().as_uri())
    except Exception:
        pass


if __name__ == "__main__":
    main()

