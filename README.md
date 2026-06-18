# Databricks on AWS - Infrastructure as Code

Terraform IaC for provisioning **Databricks on AWS** with Unity Catalog. Manages AWS infrastructure (VPC, IAM, S3), Databricks workspaces, account-level principals, and Unity Catalog resources across multiple workspaces.

---

## Technical Prerequisites

- **[Terraform](https://www.terraform.io/downloads)** `1.13.3` (recommended: [tfenv](https://github.com/tfutils/tfenv))
- **[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)** with configured credentials
- **[TFLint](https://github.com/terraform-linters/tflint)** `0.50.0`
- **[pre-commit](https://pre-commit.com/)** with [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform) `1.103.0`
- **[Git](https://git-scm.com/downloads)**

> This project was developed on **Ubuntu**. If you are on **Windows**, use **WSL2** with Ubuntu. On **macOS**, commands are similar (use `brew` instead of `apt`).

---

## Project Structure

```text
databricks_aws_infra/
├── configs/                                # YAML-driven configuration (single source of truth)
│   ├── project_configs.yml                 #   AWS region, account ID, VPC CIDR, global tags
│   ├── principal_configs.yml               #   Account-level users, groups, service principals
│   └── workspace_configs.yml               #   Per-workspace: clusters, warehouses, catalogs, budgets
│
├── stacks/                                 # Deployment units (applied in order)
│   ├── 00_bootstrap/                       #   S3 remote state backend
│   ├── 01_infra/                           #   AWS VPC, IAM, S3 root bucket, PrivateLink
│   ├── 02_account_principals/              #   Databricks account users, groups, service principals
│   ├── 03_uc_metastore/                    #   Unity Catalog metastore + storage credentials
│   └── 04_databricks_workspaces/           #   Workspace creation and configuration
│
├── modules/                                # Reusable Terraform modules
│   ├── project_data/                       #   YAML config parsing -> locals/outputs for all stacks
│   ├── aws-databricks-base-infra/          #   VPC, IAM cross-account role, root S3 bucket
│   ├── aws-databricks-unity-catalog/       #   UC metastore + storage credentials
│   ├── databricks-workspace-creation/      #   MWS API workspace provisioning
│   ├── databricks-workspace-setup/         #   Workspace resources: clusters, catalogs, permissions
│   └── account-principals-managed/         #   Account-level users, groups, service principals
│
├── scripts/                                # Helper scripts
│   ├── setup.sh                            #   Initial environment setup
│   ├── import_users.sh                     #   Import existing Databricks users into state
│   ├── import_catalogs.sh                  #   Import existing catalogs into state
│   └── install-terraform-docs.sh           #   Install terraform-docs tool
│
├── .pre-commit-config.yaml                 # Pre-commit hooks (fmt, tflint, codespell)
├── .tflint.hcl                             # TFLint configuration
├── .terraform-version                      # Pinned Terraform version (1.13.3)
├── bitbucket-pipelines.yml                 # CI/CD pipeline definition
└── CLAUDE.md                               # AI assistant context
```

---

## Configuration Architecture

All infrastructure is **configuration-driven via YAML files** in `configs/`. The `modules/project_data/` module parses these files and exposes computed locals/outputs consumed by all stacks.

| File | Purpose |
|------|---------|
| `project_configs.yml` | AWS region, Databricks account ID, VPC CIDR, global tags, storage credentials |
| `principal_configs.yml` | Account-level users, service principals, groups, and group memberships |
| `workspace_configs.yml` | Per-workspace: clusters, SQL warehouses, catalogs, schemas, external locations, group permissions, budgets |

### Adding Users or Groups

1. Edit `configs/principal_configs.yml` to add users, service principals, or groups.
2. Edit `configs/workspace_configs.yml` to assign groups to workspaces with specific privileges (e.g., `USE_CATALOG`, `CAN_MANAGE`, `ADMIN`).

### Access Control Hierarchy

```
Account -> Workspace -> Catalog -> Schema -> External Location
```

---

## Setup

### 1. Install tools

```bash
# Install Terraform via tfenv
tfenv install
tfenv use

# Install pre-commit hooks
pip install pre-commit
pre-commit install
```

### 2. Configure environment

```bash
# Copy and fill in your environment variables
cp .env.example .env

# Run the setup script
bash scripts/setup.sh
```

### 3. Configure YAML files

Copy and adjust the configuration files under `configs/` with your AWS region, Databricks account ID, VPC settings, users, groups, and workspace definitions.

---

## Deployment

Stacks must be applied **in sequence** due to cross-stack dependencies:

### Stack 0 - Bootstrap (first-time only)

Creates the S3 backend for Terraform remote state.

```bash
cd stacks/00_bootstrap
terraform init && terraform apply
```

### Stack 1 - AWS Infrastructure

Provisions the VPC, IAM cross-account role, root S3 bucket, and PrivateLink endpoints.

```bash
cd stacks/01_infra
terraform init && terraform apply
```

### Stack 2 - Account Principals

Creates Databricks account-level users, service principals, and groups.

```bash
cd stacks/02_account_principals
terraform init && terraform apply
```

### Stack 3 - Unity Catalog Metastore

Sets up the Unity Catalog metastore and storage credentials.

```bash
cd stacks/03_uc_metastore
terraform init && terraform apply
```

### Stack 4 - Databricks Workspaces

Creates and configures all workspaces (clusters, SQL warehouses, catalogs, schemas, permissions, budgets).

```bash
cd stacks/04_databricks_workspaces
terraform init && terraform apply
```

---

## Quality Guardrails

### Pre-commit hooks

Runs formatting, linting, and spell checking automatically on every commit:

```bash
pre-commit run -a          # Run all hooks manually
```

### TFLint

```bash
tflint --init && tflint --recursive
```

### Terraform formatting

```bash
terraform fmt -check -recursive
```

---

## References

- [Databricks on AWS - Terraform provider](https://registry.terraform.io/providers/databricks/databricks/latest/docs)
- [HashiCorp module structure](https://developer.hashicorp.com/terraform/language/modules/develop/structure)
- [S3 backend configuration](https://developer.hashicorp.com/terraform/language/backend/s3)
- [TFLint](https://github.com/terraform-linters/tflint)
- [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform)
