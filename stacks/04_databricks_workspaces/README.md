FAQ

1 - schema or catalog already exists:
- import it to state using for example:
```sh
terraform import 'module.workspace_setup.module.databricks_workspace_configuration.databricks_schema.dev_schemas["Example User"]' project_dev_db.dev_example_user

terraform import 'module.workspace_setup.module.databricks_workspace_configuration.databricks_catalog.catalogs["project_prod_db"]' project_prod_db
```
