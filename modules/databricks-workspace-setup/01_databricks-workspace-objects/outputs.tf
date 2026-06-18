output "cluster_id" {
  value = { for k, v in databricks_cluster.all_purpose : k => v.cluster_id }
}

output "cluster_name" {
  value = { for k, v in databricks_cluster.all_purpose : k => v.cluster_name }
}

output "sql_endpoint_ids_and_names" {
  value = merge(
    { (databricks_sql_endpoint.default_sql_wh.name) = databricks_sql_endpoint.default_sql_wh.id },
    { for k, v in databricks_sql_endpoint.warehouses : v.name => v.id }
  )
}
