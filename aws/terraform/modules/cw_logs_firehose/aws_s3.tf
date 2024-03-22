module "aws_s3_bucket_core" {
  source = "../../shared_modules/aws_s3_bucket_core"

  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info
}
