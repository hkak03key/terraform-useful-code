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
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/env" : "ci-tf-module"
          }
        }
      },
    ]
  })
}
