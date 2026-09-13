# Configuration Reference

All platform behavior comes from three YAML files in [`configs/`](../configs/). They are parsed by [`modules/project_data`](../modules/project_data/), which fills in the defaults listed below.

Conventions used in this document:

- **Req.** means the field is required. `—` in the default column means there is no default.
- Names containing `-` are converted to `_` for catalogs, schemas, external locations and federated catalogs.

- [project_configs.yml](#project_configsyml)
- [principal_configs.yml](#principal_configsyml)
- [workspace_configs.yml](#workspace_configsyml)

---

## `project_configs.yml`

Global, account-wide settings. Used by every stack.

| Field | Req. | Default | Description |
|-------|:----:|---------|-------------|
| `project_name` | ✔ | — | Prefix for most AWS/Databricks resource names (VPC, roles, MWS objects) |
| `aws_region` | ✔ | — | Region for all resources and the UC metastore |
| `aws_profile` | | — | Informational; the providers use the ambient AWS credentials |
| `databricks_account_id` | ✔ | — | Databricks account ID (account console → top-right menu) |
| `env` | | `dev` | Added to `default_tags` as `Env` |
| `backend_state_bucket_name` | | `<project_name>-tfstate` | S3 bucket for remote state (created by `00_bootstrap`) |
| `vpc_config.already_created` / `vpc_id` | | — | Reserved for bring-your-own VPC (not implemented yet) |
| `network.cidr_block` | | `10.20.0.0/16` | VPC CIDR |
| `metastore_config.metastore_bucket_name` | ✔ | — | Root + metastore S3 bucket (globally unique) |
| `metastore_config.metastore_name` | ✔ | — | UC metastore name |
| `metastore_config.reuse_metastore` | ✔ | — | `true` = look up an existing bucket and metastore instead of creating them (set the ID in `stacks/03_uc_metastore/main.tf`) |
| `account_configs.admin_group` | ✔ | — | Account-admin group. Created in `02`, becomes metastore owner and workspace ADMIN everywhere |
| `default_tags` | | `{}` | Merged over `Source`, `Region`, `Env` and `Project` |
| `storage_credential_configs` | | `{}` | Map of UC storage credentials (see below) |
| `enable_backend_private_link` | | `false` | Create Databricks back-end PrivateLink endpoints in `01_infra` |
| `workspace_endpoint_service` | if PL | `null` | Regional `com.amazonaws.vpce.<region>.vpce-svc-…` for the REST API |
| `cluster_relay_endpoint_service` | if PL | `null` | Regional SCC relay endpoint service |
| `service_direct_endpoint_service` | | `null` | Optional service-direct endpoint |

### `storage_credential_configs.<key>`

Each key creates one IAM role (`<project_name>-uc-access-<key>`), optionally one S3 bucket, and one UC storage credential.

| Field | Req. | Default | Description |
|-------|:----:|---------|-------------|
| `name` | ✔ | — | Storage credential name in Unity Catalog |
| `bucket_name` | ✔ | — | Target bucket |
| `create_bucket` | | `false` | Create the bucket (TLS-only, SSE, role-restricted policy). If `false`, the bucket must already exist |
| `prefix` | | `*` | Limit object access to `s3://bucket/<prefix>/*` |

```
storage_credential_configs:
  core_prod:
    name: project-dbk-uc-prod-access
    bucket_name: project-dbk-coreprod-bucket
    create_bucket: true
    prefix: "*"
```

---

## `principal_configs.yml`

Account-level identities. Applied by `02_account_principals`.

```
account_principals:
  service_principals: []
  groups:
    - name: project-sandbox-admins
      description: admins for the sandbox workspace
  users:
    - name: Rafael Andrade
      email: user@example.com
      allow_cluster_create: true
      groups: [project-sandbox-admins, project-sandbox-users]
```

### `users[]`

| Field | Req. | Default | Description |
|-------|:----:|---------|-------------|
| `email` | ✔ | — | Login / `user_name` |
| `name` | | email | Display name. Also used to build the dev schema name `dev_<name>` |
| `allow_cluster_create` | | `false` | Unrestricted cluster creation entitlement |
| `groups` | | `[]` | Group names. Memberships for groups this config doesn't know about are skipped (and counted in the `membership_debug` output) |

### `groups[]`

| Field | Req. | Default | Description |
|-------|:----:|---------|-------------|
| `name` | ✔ | — | Group display name |
| `description` | | — | Informational |
| `skip_create` | | `false` | `true` = the group already exists and is only looked up |
| `permissions` | | `[]` | Account rule set granting roles *on the group* (see below) |

### `service_principals[]`

| Field | Req. | Default | Description |
|-------|:----:|---------|-------------|
| `name` | ✔ | — | Key / default display name |
| `display_name` | | `name` | Display name |
| `groups` | | `[]` | Group memberships |
| `permissions` | | `[]` | Account rule set on the SP |

### `permissions[]` (groups and service principals)

```
permissions:
  - role: [Manage]            # "Manage" becomes roles/*.manager; anything else becomes roles/*.user
    principals:
      - { type: group, name: project-sandbox-admins }
      - { type: user,  name: someone@example.com }
      - { type: servicePrincipal, name: <application-id> }
```

---

## `workspace_configs.yml`

One entry per workspace under `workspaces:`. Applied by `04_databricks_workspaces`.

### Workspace fields

| Field | Req. | Default | Description |
|-------|:----:|---------|-------------|
| `name` | ✔ | — | Workspace name. Must match the `local.<ws>_workspace_name` in stack 04 |
| `dev_catalog_name` | | `null` | Catalog that holds the per-user `dev_<name>` schemas. Leave it unset to disable them |
| `budget_amount` | | `0` | Monthly USD list-price threshold. `0` = no budget |
| `budget_notification_emails` | | `[]` | Recipients of budget alerts |
| `ai_gateway_budget_amount` / `ai_gateway_budget_notification_emails` | | `0` / `[]` | Separate budget filtered on the tag `ai_gateway=true` |
| `cluster_tags` | | `{}` | Tags applied to all clusters (merged with per-cluster `custom_tags`) |
| `sql_endpoint_tags` | | `{}` | Tags applied to all SQL warehouses |
| `all_purpose_clusters` | | `[]` | See below |
| `sql_warehouses` | | `[]` | See below. A default warehouse `<name>-default-sql-wh` is **always** created |
| `catalogs` | | `[]` | See below |
| `schemas` | | `[]` | See below |
| `external_locations` | | `[]` | See below |
| `storage_credential_names` | | `[]` | Storage credentials to **bind** to this workspace (required for ISOLATED credentials) |
| `federated_catalogs` | | `[]` | Lakehouse Federation (see below) |
| `groups` | | `[]` | Group assignments and grants (see below) |

### `all_purpose_clusters[]`

Only `name` is required.

| Field | Default |
|-------|---------|
| `min_workers` / `max_workers` | `1` / `2` (autoscale; ignored if `num_workers` is set) |
| `num_workers` | unset (fixed size when set) |
| `autotermination_minutes` | `15` |
| `spark_version` | Latest LTS Spark 4, Scala 2.13 |
| `node_type_id` / `driver_node_type_id` | Smallest node with local disk and IO cache |
| `data_security_mode` | `DATA_SECURITY_MODE_STANDARD` (UC shared access) |
| `runtime_engine` | `STANDARD` (set `PHOTON` for Photon) |
| `kind` | `CLASSIC_PREVIEW` |
| `is_pinned` | `true` |
| `single_user_name`, `spark_conf`, `spark_env_vars`, `custom_tags` | unset |
| `aws_attributes`, `cluster_log_conf`, `init_scripts`, `library` | unset. Same shape as the Databricks provider blocks |

### `sql_warehouses[]`

| Field | Req. | Default |
|-------|:----:|---------|
| `name` | ✔ | — |
| `cluster_size` | ✔ | — (`2X-Small` … `4X-Large`) |
| `max_num_clusters` | ✔ | — |
| `min_num_clusters` | | `1` |
| `warehouse_type` | | `PRO` |
| `auto_stop_mins` | | `10` |
| `enable_serverless_compute` | | `false` |
| `enable_photon` | | `false` |
| `spot_instance_policy` | | `COST_OPTIMIZED` |
| `channel` | | `CHANNEL_NAME_CURRENT` |

### `catalogs[]`

This can be a plain string (`- my_catalog`) or an object:

| Field | Default | Description |
|-------|---------|-------------|
| `name` | — | Catalog name |
| `isolation_mode` | `ISOLATED` | `ISOLATED` (only bound workspaces) or `OPEN` |
| `purpose` | `Workspace catalog` | Becomes the catalog comment |
| `storage_root` | metastore root | e.g. `s3://bucket/path`. Needs a matching external location |

### `schemas[]`

One entry fans out to every listed catalog.

```
schemas:
  - name: raw
    catalogs: [project_dev_db, project_qa_db, project_prod_db]
    storage_root: null   # optional
```

### `external_locations[]`

| Field | Req. | Description |
|-------|:----:|-------------|
| `name` | ✔ | UC external location name |
| `url` | ✔ | `s3://bucket/prefix/` |
| `credential_name` | ✔ | Storage credential `name` (must also appear in `storage_credential_names`) |
| `comment` | | Free text |
| `enable_file_events` | | `true` = Databricks manages SNS/SQS file notifications |
| `file_event_queue` | | `{ managed_sqs: {} }` or `{ provided_sqs: { queue_url: … } }` |

### `federated_catalogs[]`

This creates a `databricks_connection` and a foreign catalog. Secrets come from **AWS Secrets Manager** at plan time and are never stored in YAML.

```
federated_catalogs:
  - name: pg_orders
    connection_type: POSTGRESQL        # any Databricks connection type
    comment: Orders DB (read-only)
    read_only: true
    options: { host: db.internal, port: 5432 }
    secrets:
      - option_key: user
        secret_arn: arn:aws:secretsmanager:us-east-2:123456789012:secret:pg-orders
        secret_json_key: username
      - option_key: password
        secret_arn: arn:aws:secretsmanager:us-east-2:123456789012:secret:pg-orders
        secret_json_key: password
    catalog_options: { database: orders }
```

### `groups[]`: assignments and grants

The group must exist at account level (`principal_configs.yml`).

```
groups:
  - name: project-sandbox-users
    assignments:
      workspace_permissions: ["USER"]          # or ["ADMIN"]; default USER
      catalog_privileges:
        - { catalog_name: project_dev_db, privileges: ["ALL_PRIVILEGES"] }
      schema_privileges:
        - { catalog_name: project_prod_db, schema_name: mart, privileges: ["USE_SCHEMA", "SELECT"] }
      external_location_privileges:
        - { external_location_name: project_core_dev, privileges: ["READ_FILES"] }
      storage_credential_privileges:            # only applied if the credential is bound to the workspace
        - { storage_credential_name: project-dbk-uc-dev-access, privileges: ["ALL_PRIVILEGES"] }
      cluster_privileges:
        - { cluster_name: project-dbk-shared, privileges: ["CAN_RESTART"] }  # CAN_ATTACH_TO | CAN_RESTART | CAN_MANAGE
      sql_warehouse_privileges:
        - { warehouse_name: project-sandbox-sql-wh, privileges: ["CAN_USE"] } # CAN_USE | CAN_MONITOR | CAN_MANAGE
```

> **Grants are authoritative per securable.** For each catalog, schema, external location, storage credential, cluster or warehouse listed here, Terraform owns the *entire* grant/ACL list. Privileges added by hand in the UI are removed on the next apply.

`sql_warehouse_privileges` may reference the auto-created default warehouse, `<workspace-name>-default-sql-wh`.
