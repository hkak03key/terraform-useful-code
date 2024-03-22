module "aws_kms" {
  source = "../../shared_modules/aws_kms"

  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  admin_aws_iam_principals = local.admin_aws_iam_principals
  user_aws_iam_principals = flatten([
    local.readwrite_aws_iam_principals,
    local.read_aws_iam_principals,
  ])

  enable_access_with_iam_policy  = false
  enable_access_as_user_by_admin = true

  additional_kms_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "logs.${local.region}.amazonaws.com"
        },
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*",
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${local.region}:${local.aws_account_id}:log-group:${local.aws_cloudwatch_log_group_name}"
          }
        }
      }
    ]
  })
}
