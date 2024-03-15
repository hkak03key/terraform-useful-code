# deployに失敗するので、s3_core moduleを利用し、bucket policy等は独自で設定する
module "aws_s3_bucket_core" {
  source = "../../../../shared_modules/aws_s3_bucket_core"

  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  depends_on = [
    module.aws_kms,
  ]
}


resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = module.aws_s3_bucket_core.aws_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = module.aws_kms.aws_kms_key.arn
    }
    bucket_key_enabled = true
  }
}


resource "aws_s3_bucket_public_access_block" "default" {
  bucket = module.aws_s3_bucket_core.aws_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_ownership_controls" "default" {
  bucket = module.aws_s3_bucket_core.aws_s3_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


resource "aws_s3_bucket_policy" "default" {
  bucket = module.aws_s3_bucket_core.aws_s3_bucket.id
  policy = templatefile(
    "${path.module}/aws_policies/s3_bucket_policy.json.tftpl",
    {
      aws_account_id = local.aws_account_id
      region         = local.region

      aws_s3_bucket_name  = module.aws_s3_bucket_core.aws_s3_bucket.id
      aws_cloudtrail_name = local.aws_cloudtrail_name
    }
  )
}
