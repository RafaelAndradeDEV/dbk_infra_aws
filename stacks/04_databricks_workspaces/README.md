FAQ

1 - schema or catalog already exists:
- import it to state using for example:
```sh
terraform import 'module.workspace_setup.module.databricks_workspace_configuration.databricks_schema.dev_schemas["Gabriel Bernardo"]' mesh_dev_db.dev_gabriel_bernardo

terraform import 'module.workspace_setup.module.databricks_workspace_configuration.databricks_catalog.catalogs["mesh_prod_db"]' mesh_prod_db
```
