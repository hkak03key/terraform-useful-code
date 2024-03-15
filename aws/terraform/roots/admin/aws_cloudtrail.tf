module "aws_cloudtrail" {
  source = "./modules/aws_cloudtrail"

  # fixed variables
  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  # set name_suffix if needed
  # name_suffix = ""

  # add more variables here
  admin_aws_iam_principals = local.admin_aws_iam_principals
  read_aws_iam_principals = [
  ]
}
