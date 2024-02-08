module "defaults" {
  for_each = {
    no_bp_no_sse_kms = {
      server_side_encryption = {
        sse_algorithm = "AES256"
      }
      use_bucket_policy_for_access_control = false
    }
    no_bp_sse_inner_kms = {
      server_side_encryption = {
        sse_algorithm = "aws:kms"
      }
      use_bucket_policy_for_access_control = false
    }
    bp_no_sse_kms = {
      server_side_encryption = {
        sse_algorithm = "AES256"
      }
      use_bucket_policy_for_access_control = true
    }
    bp_sse_inner_kms = {
      server_side_encryption = {
        sse_algorithm = "aws:kms"
      }
      use_bucket_policy_for_access_control = true
    }
  }

  source = "../../"

  system_name              = local.system_name
  env                      = var.env
  aws_iam_policy_infos_dir = local.aws_iam_policy_infos_dir
  name_prefix              = local.name_prefix

  name_suffix = each.key != "default" ? each.key : null

  admin_aws_iam_principals = [
    local.aws_caller_identity,
  ]
  readwrite_aws_iam_principals = [
    aws_iam_role.defaults["readwrite"],
  ]
  read_aws_iam_principals = [
    aws_iam_role.defaults["read"],
  ]

  server_side_encryption               = each.value["server_side_encryption"]
  use_bucket_policy_for_access_control = each.value["use_bucket_policy_for_access_control"]
}
