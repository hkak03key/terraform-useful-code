module "defaults" {
  for_each = {
    wo_bp_wo_kms = {
      server_side_encryption = {
        sse_algorithm = "AES256"
      }
      use_bucket_policy_for_access_control = false
    }
    wo_bp_w_in_kms = {
      server_side_encryption = {
        sse_algorithm = "aws:kms"
      }
      use_bucket_policy_for_access_control = false
    }
    w_bp_wo_kms = {
      server_side_encryption = {
        sse_algorithm = "AES256"
      }
      use_bucket_policy_for_access_control = true
    }
    w_bp_w_in_kms = {
      server_side_encryption = {
        sse_algorithm = "aws:kms"
      }
      use_bucket_policy_for_access_control = true
    }
  }

  source = "../../"

  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

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
