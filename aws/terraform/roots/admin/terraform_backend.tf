module "terraform_backend_admin" {
  source = "./modules/terraform_backend"

  # fixed variables
  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  # set name_suffix if needed
  name_suffix = "admin"

  # add more variables here
  admin_aws_iam_principals = [
    local.aws_caller_identity,
  ]
  readwrite_aws_iam_principals = [
    local.aws_caller_identity,
  ]
  read_aws_iam_principals = [
  ]
}
