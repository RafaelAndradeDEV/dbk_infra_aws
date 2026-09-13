# Stack 02 — Account Principals

Manages **Databricks account-level identities**: the platform admin group, users, groups, service principals and memberships.

| | |
|---|---|
| **State key** | `account_principals/terraform.tfstate` |
| **Depends on** | `00_bootstrap` (backend). Independent of `01_infra` |
| **Consumed by** | `03_uc_metastore` (admin group becomes the metastore owner), `04_databricks_workspaces` (groups are looked up by name) |
| **Source of truth** | [`configs/principal_configs.yml`](../../configs/principal_configs.yml) and `account_configs.admin_group` in `project_configs.yml` |

## What it creates

| File | Resources |
|------|-----------|
| `account_admins.tf` | `databricks_group` named after `account_configs.admin_group`, plus `databricks_group_role` `account_admin` |
| `main.tf` → [`account-principals-managed`](../../modules/account-principals-managed/) | `databricks_user`, `databricks_service_principal`, `databricks_group`, `databricks_group_member`, and `databricks_access_control_rule_set` for group/SP manager roles |

Groups created here get the `workspace_access`, `databricks_sql_access` and `allow_cluster_create` entitlements.

## Usage

```
cd stacks/02_account_principals
terraform init
terraform apply
```

## Notes

- Users and SPs use `force = true`, so an identity that already exists in the account is **adopted** instead of causing an error.
- A group name listed under a user but missing from `groups:` is **silently skipped**. Check the module's `membership_debug` output if a membership doesn't show up.
- Removing a user from YAML removes them from the account. `disable_as_user_deletion = false` means a hard delete, not a deactivation.
- The admin group is deliberately managed outside the YAML `groups:` list, so the platform admins can't be removed by accident.

Generated reference: [TF_README.md](TF_README.md)
