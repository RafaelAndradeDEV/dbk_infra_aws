locals {
  storage_role_name = "${var.prefix}-unity-catalog-rl"

  # Full trust policy we want on the UC role after creation (adds SelfAssume).
  # NOTE: assume_role_policy changes are ignored on the role resource, so we must
  # drive updates via terraform_data triggers_replace when inputs change.
  unity_catalog_trust_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Databricks"
        Effect = "Allow"
        Principal = {
          AWS = var.databricks_uc_master_role_arn
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.databricks_account_id
          }
        }
      },
      {
        Sid    = "SelfAssume"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.unity_catalog_main_role.arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Step 1: Create role without self-assume
resource "aws_iam_role" "unity_catalog_main_role" {
  name = local.storage_role_name
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Databricks"
        Effect = "Allow"
        Principal = {
          AWS = var.databricks_uc_master_role_arn
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.databricks_account_id
          }
        }
      }
    ]
  })

  lifecycle {
    ignore_changes = [assume_role_policy]
  }
}

# Step 2: Update trust policy to add self-assume after role creation
resource "terraform_data" "update_trust_policy" {
  depends_on = [aws_iam_role.unity_catalog_main_role]

  provisioner "local-exec" {
    command = <<-EOT
      sleep 10
      aws iam update-assume-role-policy \
        --role-name ${aws_iam_role.unity_catalog_main_role.name} \
        --policy-document '${local.unity_catalog_trust_policy_json}'
    EOT
  }

  triggers_replace = [
    aws_iam_role.unity_catalog_main_role.arn,
    var.databricks_account_id,
    var.databricks_uc_master_role_arn
  ]
}

# IAM policy to grant read and write access
data "aws_iam_policy_document" "storage_s3_policy" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:GetObjectVersion"]
    resources = [
      "arn:aws:s3:::${local.root_bucket_name}/*"
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::${local.root_bucket_name}"]
  }
}

resource "aws_iam_role_policy" "uc_combined_policy" {
  name   = "${var.prefix}-uc-policy"
  role   = aws_iam_role.unity_catalog_main_role.id
  policy = data.aws_iam_policy_document.storage_s3_policy.json
}

# IAM policy to allow Databricks to manage S3 event notifications
data "aws_iam_policy_document" "file_events_policy" {
  statement {
    sid    = "ManagedFileEventsSetupStatement"
    effect = "Allow"
    actions = [
      "s3:GetBucketNotification",
      "s3:PutBucketNotification",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:CreateTopic",
      "sns:TagResource",
      "sns:Publish",
      "sns:Subscribe",
      "sqs:CreateQueue",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:GetQueueUrl",
      "sqs:GetQueueAttributes",
      "sqs:SetQueueAttributes",
      "sqs:TagQueue",
      "sqs:ChangeMessageVisibility",
      "sqs:PurgeQueue"
    ]
    resources = [
      local.root_bucket_arn,
      "arn:aws:sqs:*:*:*",
      "arn:aws:sns:*:*:*"
    ]
  }

  statement {
    sid    = "ManagedFileEventsListStatement"
    effect = "Allow"
    actions = [
      "sqs:ListQueues",
      "sqs:ListQueueTags",
      "sns:ListTopics"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ManagedFileEventsTeardownStatement"
    effect = "Allow"
    actions = [
      "sns:Unsubscribe",
      "sns:DeleteTopic",
      "sqs:DeleteQueue"
    ]
    resources = [
      "arn:aws:sqs:*:*:*",
      "arn:aws:sns:*:*:*"
    ]
  }
}

resource "aws_iam_role_policy" "file_events_policy" {
  name   = "${var.prefix}-uc-file-events-policy"
  role   = aws_iam_role.unity_catalog_main_role.id
  policy = data.aws_iam_policy_document.file_events_policy.json
}
