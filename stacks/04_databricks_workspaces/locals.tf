locals {
  sandbox_workspace_name               = "project-sandbox"
  private_subnet_all                   = data.terraform_remote_state.infra.outputs.private_subnet_ids
  security_group_ids                   = data.terraform_remote_state.infra.outputs.security_group_ids
  sandbox_workspace_private_subnet_ids = [local.private_subnet_all[0], local.private_subnet_all[1]]
}
