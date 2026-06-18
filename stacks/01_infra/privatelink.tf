locals {
  enable_backend_private_link = module.project_data.enable_backend_private_link

  _privatelink_services_set = (
    module.project_data.workspace_endpoint_service != null &&
    module.project_data.workspace_endpoint_service != "" &&
    module.project_data.cluster_relay_endpoint_service != null &&
    module.project_data.cluster_relay_endpoint_service != ""
  )
}

resource "terraform_data" "validate_backend_privatelink_service_region" {
  count = local.enable_backend_private_link ? 1 : 0

  input = {
    aws_region                     = module.project_data.aws_region
    workspace_endpoint_service     = module.project_data.workspace_endpoint_service
    cluster_relay_endpoint_service = module.project_data.cluster_relay_endpoint_service
  }

  lifecycle {
    precondition {
      condition = (
        local._privatelink_services_set &&
        can(regex("vpce\\.${module.project_data.aws_region}\\.", module.project_data.workspace_endpoint_service)) &&
        can(regex("vpce\\.${module.project_data.aws_region}\\.", module.project_data.cluster_relay_endpoint_service))
      )
      error_message = "Back-end PrivateLink is enabled, but service names are missing or do not match aws_region `${module.project_data.aws_region}`. Update configs/project_configs.yml (enable_backend_private_link, workspace_endpoint_service, cluster_relay_endpoint_service)."
    }
  }
}
