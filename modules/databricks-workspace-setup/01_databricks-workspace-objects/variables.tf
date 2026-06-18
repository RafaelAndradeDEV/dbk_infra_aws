variable "admin_group_principal_id" { type = string }
variable "default_sql_wh_name" { type = string }
variable "cluster_tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the cluster"
}
variable "sql_endpoint_tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the SQL warehouse"
}
variable "catalogs" {
  type = list(object({
    name           = string
    isolation_mode = string
    purpose        = string
    storage_root   = optional(string)
  }))
  default = []
}

variable "schemas" {
  type = list(object({
    name         = string
    catalogs     = list(string)
    storage_root = optional(string)
  }))
  default     = []
  description = "List of schemas to create across specified catalogs"
}

variable "dev_schema_catalog_name" {
  type        = string
  description = "The name of the catalog where dev schemas will be created."
}

variable "users" {
  type = list(object({
    name  = string
    email = string
  }))
  default = []
}

variable "all_purpose_clusters" {
  type = list(object({
    name                    = string
    min_workers             = optional(number)
    max_workers             = optional(number)
    num_workers             = optional(number)
    autotermination_minutes = optional(number)
    spark_version           = optional(string)
    node_type_id            = optional(string)
    driver_node_type_id     = optional(string)
    runtime_engine          = optional(string)
    data_security_mode      = optional(string)
    single_user_name        = optional(string)
    kind                    = optional(string)
    use_ml_runtime          = optional(bool)
    enable_elastic_disk     = optional(bool)
    is_pinned               = optional(bool)
    spark_conf              = optional(map(string))
    spark_env_vars          = optional(map(string))
    custom_tags             = optional(map(string))
    init_scripts = optional(list(object({
      workspace = optional(object({ destination = string }))
      volumes   = optional(object({ destination = string }))
      dbfs      = optional(object({ destination = string }))
      s3        = optional(object({ destination = string }))
      gcs       = optional(object({ destination = string }))
      abfss     = optional(object({ destination = string }))
    })))
    aws_attributes = optional(object({
      availability           = optional(string)
      zone_id                = optional(string)
      first_on_demand        = optional(number)
      spot_bid_price_percent = optional(number)
      ebs_volume_type        = optional(string)
      ebs_volume_count       = optional(number)
      ebs_volume_size        = optional(number)
      ebs_volume_iops        = optional(number)
      ebs_volume_throughput  = optional(number)
    }))
    cluster_log_conf = optional(object({
      dbfs = optional(object({ destination = string }))
      s3 = optional(object({
        destination       = string
        region            = optional(string)
        endpoint          = optional(string)
        enable_encryption = optional(bool)
        encryption_type   = optional(string)
        kms_key           = optional(string)
        canned_acl        = optional(string)
      }))
    }))
    library = optional(list(object({
      jar   = optional(string)
      egg   = optional(string)
      whl   = optional(string)
      pypi  = optional(object({ package = string, repo = optional(string) }))
      maven = optional(object({ coordinates = string, repo = optional(string), exclusions = optional(list(string)) }))
      cran  = optional(object({ package = string, repo = optional(string) }))
    })))
  }))
  default     = []
  description = "List of all-purpose clusters to create. All fields except 'name' are optional with sensible defaults."
}

variable "federated_catalogs" {
  type = list(object({
    name            = string
    connection_type = string
    comment         = optional(string)
    read_only       = optional(bool)
    options         = map(string)
    secrets = optional(list(object({
      option_key      = string
      secret_arn      = string
      secret_json_key = string
    })), [])
    catalog_options = optional(map(string), {})
  }))
  default     = []
  description = "List of federated catalog definitions. Supports any Databricks connection type. Non-sensitive connection options go in 'options'; secrets fetched from AWS Secrets Manager go in 'secrets'."
}

variable "sql_warehouses" {
  type = list(object({
    name                      = string
    cluster_size              = string
    max_num_clusters          = number
    min_num_clusters          = optional(number)
    warehouse_type            = optional(string)
    auto_stop_mins            = optional(number)
    spot_instance_policy      = optional(string)
    enable_photon             = optional(bool)
    enable_serverless_compute = optional(bool)
    channel                   = optional(string)
  }))
  default     = []
  description = "List of SQL warehouses to create"
}
