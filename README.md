# Terraform Infrastructure

## Overview

This repository contains the **Infrastructure-as-Code (IaC)** definitions for BondBridg using **Terraform**. The setup is designed modularly to support multiple environments (dev, staging, production) while ensuring reproducibility, version control, and automated provisioning of cloud resources.

With this structure we achieve:

- **Consistency** – identical environments instantiated from the same code base  
- **Repeatability & versioning** – infrastructure changes tracked in Git, reviewable, auditable, and roll-backable  
- **Scalability & maintainability** – clean modular organization that simplifies future extensions  

## Repository Structure

```text
infrastructure/
├── modules/          ← Reusable Terraform modules (networking, database, storage, Kubernetes, etc.)
├── envs/             ← Environment-specific configurations and module composition
├── platform/         ← Global/shared infrastructure used across all environments
├── providers.tf      ← Provider configuration and required providers
├── variables.tf      ← Global variables for root modules
```

This layered + modular layout follows Terraform best practices by separating reusable modules from environment-specific configurations and avoiding monolithic root modules.

The `.gitignore` ensures sensitive state files (`terraform.tfstate*`), plan outputs, and plugin binaries are never committed — keeping the repository clean and secure.

## Module & Environment Design

### Modules (`modules/`)

Each module encapsulates a single domain of cloud resources (e.g., VPC/networking, RDS database, S3 storage, EKS cluster). Modules follow standard conventions:

- `main.tf` – resource definitions  
- `variables.tf` – input variables  
- `outputs.tf` – exported values  
- `versions.tf` *(optional)* – provider and Terraform version constraints  

**Benefits of modular design**

- Clear separation of concerns  
- High reusability across environments  
- Explicit inputs/outputs → visible dependencies  
- Easier testing and independent development  

### Environments (`envs/`)

Environment-specific configurations live under `envs/`. Each subdirectory (e.g., `dev/`, `staging/`, `prod/`) contains:

- `backend.tf` (or references a shared backend config)  
- `terraform.tfvars` with environment-specific values (region, instance sizes, tags, secrets, etc.)  
- Root module composition that calls the reusable modules  

This pattern eliminates duplication and prevents configuration drift between environments.

## Workflow & Usage

1. **Define or modify infrastructure** – add/update modules or environment variables  
2. **Commit & review** – changes go through Git + Pull Request process  
3. **Run Terraform** from the desired environment folder:

   ```bash
   cd envs/<environment>
   terraform init
   terraform plan
   terraform apply
   ```

4. **Review outputs** – module outputs provide endpoints, IDs, connection strings, etc.  
5. **Repeat** – for new features, scaling, or environment replication/destruction  

Infrastructure becomes fully reproducible, auditable, and no longer relies on manual click-ops.

## Benefits & Cloud-Native Alignment

| Benefit                    | Description                                                                 |
|----------------------------|-----------------------------------------------------------------------------|
| **Infrastructure as Code** | Everything defined in version-controlled files                              |
| **Environment Parity**     | Dev, staging, and prod run identical infrastructure                        |
| **Modular & Composable**   | Logical grouping of resources, easy to extend                               |
| **Collaboration & Review** | Infra changes follow the same PR/code-review process as application code   |
| **Clean Separation**       | Infrastructure independent from application code → easier onboarding & auditing |

These principles align with modern cloud-native practices and enable reliable, maintainable scaling.