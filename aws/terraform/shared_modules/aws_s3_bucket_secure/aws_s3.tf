/************************
# Bucket
************************/
module "aws_s3_bucket_core" {
  source = "../aws_s3_bucket_core"

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
      sse_algorithm     = var.server_side_encryption["sse_algorithm"]
      kms_master_key_id = local.aws_kms_key != null ? local.aws_kms_key.arn : null
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


/************************
# Bucket Policy
ref:
- https://aws.amazon.com/jp/premiumsupport/knowledge-center/s3-bucket-store-kms-encrypted-objects/
- https://dev.classmethod.jp/articles/s3-bucket-acces-to-a-specific-role/
************************/
resource "aws_s3_bucket_policy" "default" {
  count = (
    (
      var.server_side_encryption["sse_algorithm"] == "aws:kms"
      || var.use_bucket_policy_for_access_control == true
    )
    ? 1
    : 0
  )


  bucket = module.aws_s3_bucket_core.aws_s3_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}


data "aws_iam_policy_document" "bucket_policy" {
  source_policy_documents = flatten([
    var.server_side_encryption["sse_algorithm"] == "aws:kms" ? [
      data.aws_iam_policy_document.force_kms_encrypt_bucket_policy[0].json
    ] : [],
    var.use_bucket_policy_for_access_control == true ? [
      data.aws_iam_policy_document.s3_deny_excluding_specified_iam_ids_bucket_policy[0].json
    ] : [],
  ])
}


data "aws_iam_policy_document" "force_kms_encrypt_bucket_policy" {
  count = (
    var.server_side_encryption["sse_algorithm"] == "aws:kms"
    ? 1
    : 0
  )

  source_policy_documents = [templatefile(
    "${path.module}/aws_policies/force_kms_encrypt_bucket_policy.json.tftpl",
    {
      aws_account_id     = local.aws_account_id
      region             = local.region
      aws_s3_bucket_name = module.aws_s3_bucket_core.aws_s3_bucket.id
      aws_kms_key_id     = local.aws_kms_key.key_id
    }
  )]
}


data "aws_iam_policy_document" "s3_deny_excluding_specified_iam_ids_bucket_policy" {
  count = var.use_bucket_policy_for_access_control == true ? 1 : 0

  source_policy_documents = [templatefile(
    "${path.module}/aws_policies/s3_deny_excluding_specified_iam_ids_bucket_policy.json.tftpl",
    {
      aws_account_id     = local.aws_account_id
      aws_s3_bucket_name = module.aws_s3_bucket_core.aws_s3_bucket.id
      admin_aws_iam_principal_unique_ids = [
        for p in local.admin_aws_iam_principals :
        try(regex("^AROA.*", p.unique_id), null) != null ? "${p.unique_id}:*" : p.unique_id
      ]
      user_aws_iam_principal_unique_ids = [
        for p in local.readwrite_aws_iam_principals :
        try(regex("^AROA.*", p.unique_id), null) != null ? "${p.unique_id}:*" : p.unique_id
      ]
      readonly_user_aws_iam_principal_unique_ids = [
        for p in local.read_aws_iam_principals :
        try(regex("^AROA.*", p.unique_id), null) != null ? "${p.unique_id}:*" : p.unique_id
      ]
    }
  )]
}
