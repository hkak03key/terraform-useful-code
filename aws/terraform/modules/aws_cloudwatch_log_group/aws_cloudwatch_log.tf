/* Resource */
resource "aws_cloudwatch_log_group" "default" {
  name = local.name_prefix

  retention_in_days = 30 # FIXME
}


/* IAM Policy */
locals {
  _aws_iam_policy_aws_cloudwatch_log_group_logs_log = jsondecode(
    templatefile(
      "${local._system_info["aws_iam_policy_infos_dir"]}/logs_log.json.tftpl",
      {
        # iam policyに関する情報
        iam_policy_aws_account_id = local.aws_account_id
        # アクセスしたいリソースに関する情報
        resource_aws_account_id = local.aws_account_id
        resource_region         = local.region
        resource_name           = aws_cloudwatch_log_group.default.name
      }
    )
  )
}


resource "aws_iam_policy" "logs_log" {
  name        = local._aws_iam_policy_aws_cloudwatch_log_group_logs_log["name"]
  path        = "/"
  description = ""

  policy = jsonencode(local._aws_iam_policy_aws_cloudwatch_log_group_logs_log["policy"])
}
