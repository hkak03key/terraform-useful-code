data "aws_iam_policy" "aws_managed" {
  for_each = toset([
    "AdministratorAccess",
    "ReadOnlyAccess",
  ])

  arn = "arn:aws:iam::aws:policy/${each.value}"
}


resource "aws_iam_policy" "administrator_access_for_ci_tf_module" {
  name        = "administrator-access-for-ci-tf-module"
  description = ""
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "TagBasedAccess"
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringEquals = {
            for k in [
              "aws:RequestTag/env",
              "aws:ResourceTag/env",
            ] : k => "ci-tf-module"
          }
        }
      },
      {
        # Tag Based Accessができないリソース
        Sid    = "ResourceNameBasedAccess"
        Effect = "Allow"
        Action = "*"
        Resource = [
          "arn:aws:kms:*:*:alias/ci-tf-module-*",
          "arn:aws:dynamodb:*:*:table/ci-tf-module-*",
          "arn:aws:s3:::${var.account_name != null ? var.account_name : local.aws_account_id}-ci-tf-module-*",
          "arn:aws:iam::*:role/ci-tf-module-*",
          "arn:aws:iam::*:policy/*-ci-tf-module-*",
          "arn:aws:iam::*:policy/*-c-tf-mdl-*",
        ]
      }
    ]
  })
}
