resource "aws_cloudwatch_log_group" "default" {
  name = local.name_prefix

  retention_in_days = 30 # FIXME
}


locals {
  _aws_iam_policy_aws_cloudwatch_log_group_default = jsondecode(
    templatefile(
      "${var._system_info["aws_iam_policy_infos_dir"]}/logs_log.json.tftpl",
      {
        aws_account_id                          = local.aws_account_id # iam policyが作成されるawsアカウントID
        aws_cloudwatch_log_group_aws_account_id = local.aws_account_id # アクセスしたいcloudwatch log groupが存在するawsアカウントID
        aws_cloudwatch_log_group_region         = local.region
        aws_cloudwatch_log_group_name           = aws_cloudwatch_log_group.default.name
      }
    )
  )
}


resource "aws_iam_policy" "default" {
  name        = local._aws_iam_policy_aws_cloudwatch_log_group_default["name"]
  path        = "/"
  description = ""

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode(local._aws_iam_policy_aws_cloudwatch_log_group_default["policy"])
}
