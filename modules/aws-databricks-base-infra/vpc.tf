data "aws_availability_zones" "available" {
  region = var.aws_region
}

# For Interface VPC endpoints, AWS requires at most one subnet per Availability Zone.
data "aws_subnet" "private_by_id" {
  for_each = { for idx, id in module.vpc.private_subnets : tostring(idx) => id }
  id       = each.value
}

# TODO: Each workspace needs 2 private subnets so add more as needed
locals {
  vpc_prefix_length = tonumber(element(split("/", var.cidr_block), 1))
  private_newbits   = var.private_subnet_prefix_length - local.vpc_prefix_length
  public_subnets    = [cidrsubnet(var.cidr_block, local.private_newbits, 0)]
  private_subnets   = [for i in range(var.subnet_block_to_create) : cidrsubnet(var.cidr_block, local.private_newbits, i + 1)]

  # Pick one subnet per AZ for Interface endpoints (STS/Kinesis/Databricks back-end PrivateLink).
  _private_subnet_ids_by_az = {
    for az in distinct([for s in data.aws_subnet.private_by_id : s.availability_zone]) :
    az => sort([for _, s in data.aws_subnet.private_by_id : s.id if s.availability_zone == az])
  }
  interface_endpoint_subnet_ids = [
    for az in sort(keys(local._private_subnet_ids_by_az)) :
    local._private_subnet_ids_by_az[az][0]
  ]
}

# VPC for this deployment
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name = var.prefix
  cidr = var.cidr_block
  azs  = data.aws_availability_zones.available.names
  tags = var.tags

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  create_igw           = true


  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  manage_default_security_group = true
  default_security_group_name   = "${var.prefix}-sg"

  default_security_group_egress = [{
    cidr_blocks = "0.0.0.0/0"
  }]

  default_security_group_ingress = [{
    description = "Allow all internal TCP and UDP"
    self        = true
  }]
}

# Additional egress-only security group for workspace creation
# TODO: Each workspace needs a separate security group so add more as needed
resource "aws_security_group" "extra_sg" {
  name        = "${var.prefix}-egress-sg"
  description = "Egress-only security group"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.prefix}-egress-sg" })
}

# Create a VPC endpoint for S3 so that the root bucket can be accessed from the workspace through private link
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.7.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]

  endpoints = {
    for k, v in merge(
      {
        s3 = {
          service      = "s3"
          service_type = "Gateway"
          route_table_ids = flatten([
            module.vpc.private_route_table_ids,
          module.vpc.public_route_table_ids])
          tags = {
            Name = "${var.prefix}-s3-vpc-endpoint"
          }
        },
        sts = {
          service             = "sts"
          service_type        = "Interface"
          route_table_ids     = flatten([module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
          private_dns_enabled = null
          tags = {
            Name = "${var.prefix}-sts-vpc-endpoint"
          }
        },
        "kinesis-streams" = {
          service             = "kinesis-streams"
          service_type        = "Interface"
          route_table_ids     = flatten([module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
          private_dns_enabled = null
          tags = {
            Name = "${var.prefix}-kinesis-streams-vpc-endpoint"
          }
        },
        # S3 Interface endpoint complements the Gateway endpoint by covering S3 IPs that
        # fall outside the Gateway prefix list. With private DNS enabled, all S3 traffic
        # resolves to private IPs regardless of IP range.
        "s3-interface" = {
          service             = "s3"
          service_type        = "Interface"
          subnet_ids          = local.interface_endpoint_subnet_ids
          private_dns_enabled = true
          tags = {
            Name = "${var.prefix}-s3-interface-vpc-endpoint"
          }
        }
      },
      var.enable_backend_private_link ? {
        databricks_workspace = {
          service_name        = var.workspace_endpoint_service
          service_type        = "Interface"
          subnet_ids          = local.interface_endpoint_subnet_ids
          private_dns_enabled = true
          security_group_ids  = [aws_security_group.databricks_workspace_vpce[0].id]
          tags = {
            Name = "${var.prefix}-databricks-workspace-vpce"
          }
        },
        databricks_relay = {
          service_name        = var.cluster_relay_endpoint_service
          service_type        = "Interface"
          subnet_ids          = local.interface_endpoint_subnet_ids
          private_dns_enabled = true
          security_group_ids  = [aws_security_group.databricks_scc_vpce[0].id]
          tags = {
            Name = "${var.prefix}-databricks-relay-vpce"
          }
        }
      } : {},
      # Service-direct endpoint: covers Databricks telemetry and direct service access.
      # Optional but recommended — routes EC2-addressed Databricks traffic off the internet.
      var.enable_backend_private_link && var.service_direct_endpoint_service != null ? {
        databricks_service_direct = {
          service_name        = var.service_direct_endpoint_service
          service_type        = "Interface"
          subnet_ids          = local.interface_endpoint_subnet_ids
          private_dns_enabled = true
          security_group_ids  = [module.vpc.default_security_group_id]
          tags = {
            Name = "${var.prefix}-databricks-service-direct-vpce"
          }
        }
      } : {}
    ) : k => v
  }
  tags = var.tags
}

locals {
  dataplane_security_group_id = coalesce(
    var.databricks_dataplane_security_group_id,
    try(module.vpc.default_security_group_id, null)
  )
}

resource "terraform_data" "validate_backend_privatelink" {
  count = var.enable_backend_private_link ? 1 : 0

  input = {
    workspace_endpoint_service     = var.workspace_endpoint_service
    cluster_relay_endpoint_service = var.cluster_relay_endpoint_service
    dataplane_security_group_id    = local.dataplane_security_group_id
    vpc_id                         = module.vpc.vpc_id
  }

  lifecycle {
    precondition {
      condition     = var.workspace_endpoint_service != null && var.workspace_endpoint_service != ""
      error_message = "enable_backend_private_link=true requires workspace_endpoint_service to be set."
    }
    precondition {
      condition     = var.cluster_relay_endpoint_service != null && var.cluster_relay_endpoint_service != ""
      error_message = "enable_backend_private_link=true requires cluster_relay_endpoint_service to be set."
    }
    precondition {
      condition     = local.dataplane_security_group_id != null && local.dataplane_security_group_id != ""
      error_message = "enable_backend_private_link=true requires a dataplane security group ID (set databricks_dataplane_security_group_id or ensure effective_security_group_ids is non-empty)."
    }
  }
}

# Dedicated security groups for Databricks back-end PrivateLink interface endpoints.
resource "aws_security_group" "databricks_workspace_vpce" {
  count       = var.enable_backend_private_link ? 1 : 0
  name        = "${var.prefix}-workspace-vpce-sg"
  description = "Security group for Databricks workspace (REST API) VPC endpoint"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }
  ingress {
    from_port       = 2443
    to_port         = 2443
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }
  ingress {
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }
  ingress {
    from_port       = 8444
    to_port         = 8444
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }
  ingress {
    from_port       = 8445
    to_port         = 8451
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }
  egress {
    from_port       = 2443
    to_port         = 2443
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }
  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }
  egress {
    from_port       = 8443
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }
  egress {
    from_port       = 8444
    to_port         = 8444
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }
  egress {
    from_port       = 8445
    to_port         = 8451
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }

  tags = merge(var.tags, { Name = "${var.prefix}-workspace-vpce-sg" })

  depends_on = [terraform_data.validate_backend_privatelink]
}

resource "aws_security_group" "databricks_scc_vpce" {
  count       = var.enable_backend_private_link ? 1 : 0
  name        = "${var.prefix}-scc-vpce-sg"
  description = "Security group for Databricks SCC relay VPC endpoint"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 6666
    to_port         = 6666
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }
  ingress {
    from_port       = 2443
    to_port         = 2443
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }

  egress {
    from_port       = 6666
    to_port         = 6666
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }
  egress {
    from_port       = 2443
    to_port         = 2443
    protocol        = "tcp"
    security_groups = [local.dataplane_security_group_id]
  }

  tags = merge(var.tags, { Name = "${var.prefix}-scc-vpce-sg" })

  depends_on = [terraform_data.validate_backend_privatelink]
}

# Register the AWS VPC endpoints with Databricks (required for back-end PrivateLink).
resource "databricks_mws_vpc_endpoint" "workspace" {
  count               = var.enable_backend_private_link ? 1 : 0
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = module.vpc_endpoints.endpoints["databricks_workspace"].id
  vpc_endpoint_name   = "workspace-${module.vpc.vpc_id}"
  region              = var.aws_region

  depends_on = [module.vpc_endpoints, terraform_data.validate_backend_privatelink]
}

resource "databricks_mws_vpc_endpoint" "relay" {
  count               = var.enable_backend_private_link ? 1 : 0
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = module.vpc_endpoints.endpoints["databricks_relay"].id
  vpc_endpoint_name   = "relay-${module.vpc.vpc_id}"
  region              = var.aws_region

  depends_on = [module.vpc_endpoints, terraform_data.validate_backend_privatelink]
}

# Back-end PrivateLink requires Private Access Settings at the account level.
# These settings are referenced from each workspace via `private_access_settings_id`.
resource "databricks_mws_private_access_settings" "this" {
  count    = var.enable_backend_private_link ? 1 : 0
  provider = databricks
  # account_id                   = var.databricks_account_id
  private_access_settings_name = "${var.prefix}-private-access"
  region                       = var.aws_region

  # PrivateLink-only posture
  # If set to false, Terraform (and users) must access the workspace via front-end PrivateLink/VPN;
  # otherwise workspace-scoped API calls will fail with "Unauthorized network access".
  public_access_enabled = var.private_access_public_access_enabled

  # Allow only the VPC endpoints we registered in the account for back-end PrivateLink
  private_access_level = "ACCOUNT"
  # allowed_vpc_endpoint_ids = [
  #   databricks_mws_vpc_endpoint.workspace[0].vpc_endpoint_id,
  #   databricks_mws_vpc_endpoint.relay[0].vpc_endpoint_id
  # ]

  depends_on = [databricks_mws_vpc_endpoint.workspace, databricks_mws_vpc_endpoint.relay]
}
