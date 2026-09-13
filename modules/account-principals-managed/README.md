# Module: `account-principals-managed`

Manages **account-level identities** from normalized YAML input (see `modules/project_data`). Used by `stacks/02_account_principals`.

## Resources

| Resource | Behavior |
|----------|----------|
| `databricks_user.this` | One per unique email. `force = true` adopts existing users |
| `databricks_service_principal.this` | One per SP `name` |
| `databricks_group.this` | Groups without `skip_create`. Gets `workspace_access`, `databricks_sql_access` and `allow_cluster_create` |
| `data.databricks_group.existing` | Groups with `skip_create: true` (looked up, not managed) |
| `databricks_group_member.user_membership` / `sp_membership` | Built from each user's or SP's `groups` list |
| `databricks_access_control_rule_set.group_permissions` / `sp_permissions` | Grants `roles/*.manager` (`Manage`) or `roles/*.user` on a group or SP to other principals |

## Inputs

| Input | Type |
|-------|------|
| `account_id` | `string` |
| `users` | `list({ name, email, allow_cluster_create, groups })` |
| `service_principals` | `list({ name, display_name, groups, permissions })` |
| `groups` | `list({ group_name, skip_create, permissions })` |

## Outputs

| Output | Description |
|--------|-------------|
| `groups_map` | `group_name → { id, display_name }` |
| `membership_debug` | Counts of created vs. dropped memberships. A dropped membership means a user references a group this module doesn't know about |

Requires the `databricks.mws` provider alias.

Generated reference: [TF_README.md](TF_README.md)
