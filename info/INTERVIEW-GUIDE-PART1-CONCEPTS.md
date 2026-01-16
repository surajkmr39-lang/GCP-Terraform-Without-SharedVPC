# 🎯 TERRAFORM INTERVIEW PREPARATION - PART 1: CORE CONCEPTS

## 📚 THE CONFUSION EXPLAINED (Root vs Module Files)

### **WHY DO WE HAVE DUPLICATE FILE NAMES?**

Think of it like a **company structure**:

```
Company (Root)
├── CEO Office (main.tf, variables.tf, outputs.tf)
│   └── Makes high-level decisions, coordinates departments
│
└── Departments (Modules)
    ├── HR Department (modules/iam/)
    │   ├── main.tf (HR's work)
    │   ├── variables.tf (What HR needs from CEO)
    │   └── outputs.tf (HR's results to share)
    │
    ├── IT Department (modules/network/)
    │   ├── main.tf (IT's work)
    │   ├── variables.tf (What IT needs from CEO)
    │   └── outputs.tf (IT's results to share)
    │
    └── Security Department (modules/security/)
        ├── main.tf (Security's work)
        ├── variables.tf (What Security needs)
        └── outputs.tf (Security's results)
```

### **ROOT FILES (Outside modules/)**

**Location**: `./main.tf`, `./variables.tf`, `./outputs.tf`

**Purpose**: The ORCHESTRATOR - coordinates everything

```
Root main.tf = "CEO giving orders to departments"
Root variables.tf = "Company-wide policies"
Root outputs.tf = "Company annual report"
```

### **MODULE FILES (Inside modules/network/, modules/iam/, etc.)**

**Location**: `./modules/network/main.tf`, `./modules/iam/main.tf`

**Purpose**: The WORKERS - do specific tasks

```
Module main.tf = "Department doing actual work"
Module variables.tf = "What this department needs to work"
Module outputs.tf = "Department's deliverables"
```

---

## 🔄 COMPLETE DATA FLOW (Step by Step)

### **STEP 1: You Provide Values**

**File**: `terraform.tfvars` (YOUR file, not in Git)
```hcl
project_id = "praxis-gear-483220-k4"
region     = "us-central1"
environment = "dev"
```

**File**: `environments/dev/terraform.tfvars` (Environment-specific)
```hcl
# Same values but for dev environment specifically
```

### **STEP 2: Root Declares Variables**

**File**: `./variables.tf` (ROOT)
```hcl
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}
```

**Analogy**: This is like a form with empty fields

### **STEP 3: Root Main.tf Calls Modules**

**File**: `./main.tf` (ROOT)
```hcl
module "network" {
  source = "./modules/network"
  
  project_id  = var.project_id    # ← From terraform.tfvars
  region      = var.region
  environment = var.environment
}
```

**Analogy**: CEO tells IT department: "Here's your budget and requirements"

### **STEP 4: Module Receives Variables**

**File**: `./modules/network/variables.tf` (MODULE)
```hcl
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}
```

**Analogy**: IT department receives the budget

### **STEP 5: Module Does Work**

**File**: `./modules/network/main.tf` (MODULE)
```hcl
resource "google_compute_network" "vpc" {
  name    = "${var.environment}-vpc"
  project = var.project_id
}
```

**Analogy**: IT department builds the network

### **STEP 6: Module Returns Results**

**File**: `./modules/network/outputs.tf` (MODULE)
```hcl
output "vpc_name" {
  value = google_compute_network.vpc.name
}
```

**Analogy**: IT department reports: "Network is ready, name is dev-vpc"

### **STEP 7: Root Uses Module Outputs**

**File**: `./main.tf` (ROOT)
```hcl
module "compute" {
  source = "./modules/compute"
  
  network_name = module.network.vpc_name  # ← Using IT's output
}
```

**Analogy**: CEO tells another department: "Use the network IT built"

### **STEP 8: Root Displays Final Results**

**File**: `./outputs.tf` (ROOT)
```hcl
output "network" {
  value = {
    vpc_name = module.network.vpc_name
  }
}
```

**Analogy**: Company annual report showing all achievements

---

## 🎤 INTERVIEW QUESTION 1: "Explain your Terraform project structure"

### **PERFECT ANSWER**:

"I built a modular GCP infrastructure using Terraform with a clear separation of concerns.

**Root Level** contains:
- `main.tf` - The orchestrator that calls all modules
- `variables.tf` - Declares all input variables
- `outputs.tf` - Exposes important information after deployment
- `terraform.tfvars.example` - Template for users to provide values

**Module Level** - I created 4 reusable modules:
1. **Network Module** - Creates VPC, subnets, Cloud NAT, and Router
2. **IAM Module** - Manages service accounts and Workload Identity Federation
3. **Security Module** - Defines firewall rules
4. **Compute Module** - Provisions VM instances

Each module has its own `main.tf`, `variables.tf`, and `outputs.tf` for encapsulation.

**Why this structure?**
- **Reusability**: Same modules work for dev, staging, prod
- **Maintainability**: Change one module without affecting others
- **Testing**: Test modules independently
- **Collaboration**: Teams can work on different modules

**Data Flow**: 
Root main.tf → Calls modules → Modules create resources → Modules output results → Root outputs display to user"

---

## 🎤 INTERVIEW QUESTION 2: "Why do you have variables.tf in both root and modules?"

### **PERFECT ANSWER**:

"Great question! They serve different purposes:

**Root variables.tf** (`./variables.tf`):
- Declares variables that the END USER provides
- These are the 'knobs' users can turn
- Example: project_id, region, machine_type
- Values come from `terraform.tfvars`

**Module variables.tf** (`./modules/network/variables.tf`):
- Declares what THIS MODULE needs to function
- Acts as the module's input interface
- Values come from the root main.tf when calling the module

**Example Flow**:
```
User provides: project_id = "my-project"
    ↓
Root variables.tf: Declares variable "project_id"
    ↓
Root main.tf: Passes var.project_id to module
    ↓
Module variables.tf: Receives project_id
    ↓
Module main.tf: Uses var.project_id to create resources
```

It's like a relay race - each file passes the baton to the next!"

---

## 🎤 INTERVIEW QUESTION 3: "Walk me through what happens when you run terraform apply"

### **PERFECT ANSWER**:

"When I run `terraform apply`, here's the exact sequence:

**Phase 1: Initialization** (if terraform init was run)
- Downloads Google Cloud provider plugin
- Initializes backend (local or remote state)
- Downloads any external modules

**Phase 2: Configuration Loading**
1. Terraform reads ALL `.tf` files in root directory
2. Loads `terraform.tfvars` for variable values
3. Merges all configurations into memory

**Phase 3: Dependency Graph**
- Terraform builds a dependency graph
- Determines execution order based on resource dependencies
- Example: VPC must exist before VM can use it

**Phase 4: Plan Generation**
- Compares desired state (code) with current state (tfstate file)
- Calculates what needs to be created, updated, or destroyed
- Shows me the plan for approval

**Phase 5: Execution** (after I approve)
- Executes in dependency order:
  1. **Network module**: Creates VPC, subnet, NAT, router
  2. **IAM module**: Creates service account, WIF pool (parallel with network)
  3. **Security module**: Creates firewall rules (needs VPC name)
  4. **Compute module**: Creates VM (needs VPC, subnet, service account)

**Phase 6: State Update**
- Updates `terraform.tfstate` with actual resource IDs
- Stores outputs for future reference

**Phase 7: Output Display**
- Shows me the outputs defined in `outputs.tf`
- Example: VM IP address, SSH command

**In my project**, this creates 15 resources across 4 modules in about 2-3 minutes."

---

