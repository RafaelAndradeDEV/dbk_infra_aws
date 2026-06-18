# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Terraform IaC for provisioning **Databricks on AWS** with Unity Catalog. Manages AWS infrastructure (VPC, IAM, S3), Databricks workspaces, account-level principals, and Unity Catalog resources across multiple workspaces.

## Technology Stack

- **Terraform** `1.13.3` (pinned via `.terraform-version`; use `tfenv`)
- **Providers:** `hashicorp/aws >=6.14.1`, `databricks/databricks >=1.90.0`
- **VPC Module:** `terraform-aws-modules/vpc/aws 5.7.0`
- **CI/CD:** Bitbucket Pipelines
- **Linting:** TFLint `0.50.0`, pre-commit-terraform `1.103.0`

## Common Commands

### Setup
```bash
pip install pre-commit
pre-commit install
```

### Linting & Validation
```bash
pre-commit run -a                          # Run all pre-commit hooks (fmt, tflint, spell check)
tflint --init && tflint --recursive        # Run TFLint standalone
terraform fmt -check -recursive            # Check formatting
```

### Per-stack Terraform workflow
```bash
cd stacks/<stack_name>
terraform init
terraform plan
terraform apply
```

### Bootstrap (first-time only)
```bash
cd stacks/00_bootstrap && terraform init && terraform apply
```

## Deployment Order

Stacks must be applied in sequence due to cross-stack dependencies:

1. **`00_bootstrap`** — S3 remote state backend
2. **`01_infra`** — AWS VPC, IAM roles, S3 root bucket, PrivateLink endpoints
3. **`02_account_principals`** — Databricks account users, groups, service principals
4. **`03_uc_metastore`** — Unity Catalog metastore and storage credentials
5. **`04_databricks_workspaces`** — Workspace creation and configuration (5 workspaces)

## Configuration Architecture

All infrastructure is **configuration-driven via YAML files** in `configs/`:

- **`project_configs.yml`** — AWS region, Databricks account ID, VPC CIDR, global tags, storage credentials
- **`principal_configs.yml`** — Account-level users, service principals, groups, and group memberships
- **`workspace_configs.yml`** — Per-workspace: clusters, SQL warehouses, catalogs, schemas, external locations, group permissions, budgets

The `modules/project_data/` module parses these YAMLs and exposes computed locals/outputs consumed by all stacks.

## Module Structure

```
modules/
├── project_data/                 # YAML config parsing → locals/outputs for all stacks
├── aws-databricks-base-infra/    # VPC, IAM cross-account role, root S3 bucket
├── aws-databricks-unity-catalog/ # UC metastore + storage credentials
├── databricks-workspace-creation/# MWS API workspace provisioning
├── databricks-workspace-setup/   # Workspace resources: clusters, catalogs, permissions
└── account-principals-managed/   # Account-level users, groups, service principals
```

## Workspaces

Five Databricks workspaces, each defined in a separate `.tf` file under `stacks/04_databricks_workspaces/`:

| Workspace | Purpose |
|-----------|---------|
| `indiciumai-sandbox` | Internal sandbox for quick/temporary testing (no sensitive data) |
| `indiciumai-external-sandbox` | Sandbox with external user access (no sensitive or internal data) |
| `indiciumai-analytics` | Core workspace — Data Center squad, central/corporate data products |
| `indiciumai-products` | Federated data products — non-Data Center squads, localized/specific data products |
| `indimesh-aws-bv` | BV bank project - temporary workspace that must be deleted after project is completed |

## Adding Users or Groups

Edit `configs/principal_configs.yml` to add users/service principals/groups. Edit `configs/workspace_configs.yml` to assign groups to workspaces with specific privileges (e.g., `USE_CATALOG`, `CAN_MANAGE`, `ADMIN`).

## Access Control Hierarchy

```
Account → Workspace → Catalog → Schema → External Location
```

Principal types: Users (email), Service Principals, Groups. Permissions are assigned at each level via `workspace_configs.yml`.

## Pre-commit Hooks

Configured in `.pre-commit-config.yaml`:
- `terraform_fmt` — Auto-format
- `terraform_tflint` — Lint (config in `.tflint.hcl`)
- `codespell` — Spell checking
- Standard checks: end-of-file, trailing whitespace, YAML/JSON validity, private key detection
