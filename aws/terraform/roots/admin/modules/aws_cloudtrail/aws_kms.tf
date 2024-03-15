module "aws_kms" {
  source = "../../../../shared_modules/aws_kms"

  _system_info              = local._system_info
  _module_hierarchical_info = local._module_hierarchical_info

  admin_aws_iam_principals = var.admin_aws_iam_principals
  user_aws_iam_principals = flatten([
    var.read_aws_iam_principals,
  ])

  enable_access_with_iam_policy = false
  additional_kms_policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "Key policy for CloudTrail",
    "Statement" : [
      {
        "Sid" : "AllowCloudTrailToUseKey",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : [
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowCloudTrailToCreateLogStream",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudtrail.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:Decrypt"
        ],
        "Resource" : "*"
      },
    ]
  })
}
