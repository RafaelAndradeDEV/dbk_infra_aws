data "databricks_aws_assume_role_policy" "this" {
  external_id = var.databricks_account_id
}


resource "aws_iam_role" "cross_account_role" {
  name               = "${var.prefix}-crossaccount"
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json
  tags               = var.tags
}

data "databricks_aws_crossaccount_policy" "this" {
  policy_type = "customer"
}

# Optional: allow the cross-account role to pass specific roles (e.g. a CI/ECR agent role).
data "aws_iam_policy_document" "extra_policy" {
  count = length(var.extra_pass_role_arns) > 0 ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = var.extra_pass_role_arns
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.prefix}-policy"
  role   = aws_iam_role.cross_account_role.id
  policy = data.databricks_aws_crossaccount_policy.this.json
}

resource "aws_iam_role_policy" "extra_policy" {
  count  = length(var.extra_pass_role_arns) > 0 ? 1 : 0
  name   = "${var.prefix}-extra-policy"
  role   = aws_iam_role.cross_account_role.id
  policy = data.aws_iam_policy_document.extra_policy[0].json
}

resource "time_sleep" "wait_for_group_creation" {
  depends_on      = [aws_iam_role.cross_account_role]
  create_duration = "10s"
}

resource "databricks_mws_credentials" "this" {
  role_arn         = aws_iam_role.cross_account_role.arn
  credentials_name = "${var.prefix}-creds"
  depends_on       = [aws_iam_role_policy.this, time_sleep.wait_for_group_creation]
}
