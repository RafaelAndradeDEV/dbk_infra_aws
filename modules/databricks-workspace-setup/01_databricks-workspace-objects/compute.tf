# SQL Warehouse

locals {
  # Only include tags block if there are tags to add
  has_sql_endpoint_tags = length(var.sql_endpoint_tags) > 0
}

resource "databricks_sql_endpoint" "default_sql_wh" {
  provider                  = databricks.workspace
  name                      = var.default_sql_wh_name
  cluster_size              = "2X-Small"
  max_num_clusters          = 3
  enable_serverless_compute = false
  auto_stop_mins            = 10
  no_wait                   = true
  warehouse_type            = "PRO"

  dynamic "tags" {
    for_each = local.has_sql_endpoint_tags ? [1] : []
    content {
      dynamic "custom_tags" {
        for_each = var.sql_endpoint_tags
        content {
          key   = custom_tags.key
          value = custom_tags.value
        }
      }
    }
  }
}

resource "databricks_sql_endpoint" "warehouses" {
  provider = databricks.workspace
  for_each = { for wh in var.sql_warehouses : wh.name => wh }

  name                      = each.value.name
  cluster_size              = each.value.cluster_size
  max_num_clusters          = each.value.max_num_clusters
  min_num_clusters          = coalesce(each.value.min_num_clusters, 1)
  enable_serverless_compute = coalesce(each.value.enable_serverless_compute, false)
  auto_stop_mins            = coalesce(each.value.auto_stop_mins, 10)
  warehouse_type            = coalesce(each.value.warehouse_type, "PRO")
  no_wait                   = true
  spot_instance_policy      = coalesce(each.value.spot_instance_policy, "COST_OPTIMIZED")
  enable_photon             = coalesce(each.value.enable_photon, false)
  channel {
    name = coalesce(each.value.channel, "CHANNEL_NAME_CURRENT")
  }

  dynamic "tags" {
    for_each = local.has_sql_endpoint_tags ? [1] : []
    content {
      dynamic "custom_tags" {
        for_each = var.sql_endpoint_tags
        content {
          key   = custom_tags.key
          value = custom_tags.value
        }
      }
    }
  }
}

## Cluster creation
data "databricks_node_type" "smallest" {
  provider            = databricks.workspace
  depends_on          = [databricks_permission_assignment.add_admin_spn]
  local_disk          = true
  is_io_cache_enabled = true
}

data "databricks_spark_version" "latest_lts" {
  provider      = databricks.workspace
  depends_on    = [databricks_permission_assignment.add_admin_spn]
  scala         = "2.13"
  spark_version = "4"
}

resource "databricks_cluster" "all_purpose" {
  provider   = databricks.workspace
  depends_on = [databricks_permission_assignment.add_admin_spn]
  for_each   = { for c in var.all_purpose_clusters : c.name => c }

  no_wait                 = true
  cluster_name            = each.value.name
  spark_version           = coalesce(each.value.spark_version, data.databricks_spark_version.latest_lts.id)
  node_type_id            = coalesce(each.value.node_type_id, data.databricks_node_type.smallest.id)
  driver_node_type_id     = coalesce(each.value.driver_node_type_id, data.databricks_node_type.smallest.id)
  autotermination_minutes = coalesce(each.value.autotermination_minutes, 15)
  is_pinned               = coalesce(each.value.is_pinned, true)
  data_security_mode      = coalesce(each.value.data_security_mode, "DATA_SECURITY_MODE_STANDARD")
  single_user_name        = each.value.single_user_name
  runtime_engine          = coalesce(each.value.runtime_engine, "STANDARD")
  kind                    = coalesce(each.value.kind, "CLASSIC_PREVIEW")
  spark_conf              = each.value.spark_conf
  spark_env_vars          = each.value.spark_env_vars
  custom_tags             = merge(var.cluster_tags, coalesce(each.value.custom_tags, {}))

  # Use num_workers for fixed size, or autoscale for dynamic sizing
  num_workers = each.value.num_workers

  dynamic "autoscale" {
    for_each = each.value.num_workers == null ? [1] : []
    content {
      min_workers = coalesce(each.value.min_workers, 1)
      max_workers = coalesce(each.value.max_workers, 2)
    }
  }

  dynamic "aws_attributes" {
    for_each = each.value.aws_attributes != null ? [each.value.aws_attributes] : []
    content {
      availability           = aws_attributes.value.availability
      zone_id                = aws_attributes.value.zone_id
      first_on_demand        = aws_attributes.value.first_on_demand
      spot_bid_price_percent = aws_attributes.value.spot_bid_price_percent
      ebs_volume_type        = aws_attributes.value.ebs_volume_type
      ebs_volume_count       = aws_attributes.value.ebs_volume_count
      ebs_volume_size        = aws_attributes.value.ebs_volume_size
      ebs_volume_iops        = aws_attributes.value.ebs_volume_iops
      ebs_volume_throughput  = aws_attributes.value.ebs_volume_throughput
    }
  }

  dynamic "cluster_log_conf" {
    for_each = each.value.cluster_log_conf != null ? [each.value.cluster_log_conf] : []
    content {
      dynamic "dbfs" {
        for_each = cluster_log_conf.value.dbfs != null ? [cluster_log_conf.value.dbfs] : []
        content {
          destination = dbfs.value.destination
        }
      }
      dynamic "s3" {
        for_each = cluster_log_conf.value.s3 != null ? [cluster_log_conf.value.s3] : []
        content {
          destination       = s3.value.destination
          region            = s3.value.region
          endpoint          = s3.value.endpoint
          enable_encryption = s3.value.enable_encryption
          encryption_type   = s3.value.encryption_type
          kms_key           = s3.value.kms_key
          canned_acl        = s3.value.canned_acl
        }
      }
    }
  }

  dynamic "init_scripts" {
    for_each = each.value.init_scripts != null ? each.value.init_scripts : []
    content {
      dynamic "workspace" {
        for_each = init_scripts.value.workspace != null ? [init_scripts.value.workspace] : []
        content {
          destination = workspace.value.destination
        }
      }
      dynamic "volumes" {
        for_each = init_scripts.value.volumes != null ? [init_scripts.value.volumes] : []
        content {
          destination = volumes.value.destination
        }
      }
      dynamic "dbfs" {
        for_each = init_scripts.value.dbfs != null ? [init_scripts.value.dbfs] : []
        content {
          destination = dbfs.value.destination
        }
      }
      dynamic "s3" {
        for_each = init_scripts.value.s3 != null ? [init_scripts.value.s3] : []
        content {
          destination = s3.value.destination
        }
      }
      dynamic "gcs" {
        for_each = init_scripts.value.gcs != null ? [init_scripts.value.gcs] : []
        content {
          destination = gcs.value.destination
        }
      }
      dynamic "abfss" {
        for_each = init_scripts.value.abfss != null ? [init_scripts.value.abfss] : []
        content {
          destination = abfss.value.destination
        }
      }
    }
  }

  dynamic "library" {
    for_each = each.value.library != null ? each.value.library : []
    content {
      jar = library.value.jar
      egg = library.value.egg
      whl = library.value.whl
      dynamic "pypi" {
        for_each = library.value.pypi != null ? [library.value.pypi] : []
        content {
          package = pypi.value.package
          repo    = pypi.value.repo
        }
      }
      dynamic "maven" {
        for_each = library.value.maven != null ? [library.value.maven] : []
        content {
          coordinates = maven.value.coordinates
          repo        = maven.value.repo
          exclusions  = maven.value.exclusions
        }
      }
      dynamic "cran" {
        for_each = library.value.cran != null ? [library.value.cran] : []
        content {
          package = cran.value.package
          repo    = cran.value.repo
        }
      }
    }
  }
}
