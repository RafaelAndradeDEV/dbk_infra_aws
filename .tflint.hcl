# TFLint configuration
# See: https://github.com/terraform-linters/tflint
config {
  call_module_type = "local"
  force = false
  disabled_by_default = false
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
  enabled = true
  version = "0.43.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "aws_provider_missing_default_tags" {
  enabled = true
  tags = ["ManagedBy", "Owner"]
}
