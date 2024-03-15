locals {
  # prevent for cycle
  aws_cloudtrail_name = local.name_prefix
}

resource "aws_cloudtrail" "default" {
  name                          = local.aws_cloudtrail_name
  s3_bucket_name                = module.aws_s3_bucket_core.aws_s3_bucket.bucket
  s3_key_prefix                 = ""
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true

  kms_key_id = module.aws_kms.aws_kms_key.arn

  advanced_event_selector {
    field_selector {
      equals = [
        "Management",
      ]
      field = "eventCategory"
    }
  }

  advanced_event_selector {
    field_selector {
      equals = [
        "AWS::S3::Object",
      ]
      field = "resources.type"
    }
    field_selector {
      equals = [
        "Data",
      ]
      field = "eventCategory"
    }
    field_selector {
      field = "resources.ARN"
      not_starts_with = [
        "arn:aws:s3:::${module.aws_s3_bucket_core.aws_s3_bucket.bucket}/",
      ]
    }
  }

  depends_on = [
    aws_s3_bucket_ownership_controls.default,
    aws_s3_bucket_policy.default,
  ]
}
