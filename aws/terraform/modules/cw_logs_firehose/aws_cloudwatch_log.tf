/* Resource */
locals {
  # prevent cyclic dependency
  aws_cloudwatch_log_group_name = local.name_prefix
}


resource "aws_cloudwatch_log_group" "default" {
  name = local.aws_cloudwatch_log_group_name

  retention_in_days = 30 # FIXME

  kms_key_id = module.aws_kms.aws_kms_key.arn
}


/* IAM Policy */
locals {
  _aws_iam_policy_aws_cloudwatch_log_group_logs_log = jsondecode(
    templatefile(
      "${local._system_info["aws_iam_policy_infos_dir"]}/logs_log.json.tftpl",
      {
        aws_account_id                          = local.aws_account_id # iam policyが作成されるawsアカウントID
        aws_cloudwatch_log_group_aws_account_id = local.aws_account_id # アクセスしたいcloudwatch log groupが存在するawsアカウントID
        aws_cloudwatch_log_group_region         = local.region
        aws_cloudwatch_log_group_name           = aws_cloudwatch_log_group.default.name
      }
    )
  )
}


resource "aws_iam_policy" "logs_log" {
  name        = local._aws_iam_policy_aws_cloudwatch_log_group_logs_log["name"]
  path        = "/"
  description = ""

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(local._aws_iam_policy_aws_cloudwatch_log_group_logs_log["policy"])
}
