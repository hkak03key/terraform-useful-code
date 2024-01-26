resource "aws_iam_role" "defaults" {
  for_each = toset([
    "read",
    "readwrite",
    "not_attached",
  ])

  name = replace(
    join(
      "-",
      [
        local.name_prefix,
        each.key,
        random_password.aws_iam_role_suffix.result,
      ]
  ), "_", "-")

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          AWS = local.aws_account_id
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}


resource "random_password" "aws_iam_role_suffix" {
  length  = 6
  lower   = true
  upper   = false
  special = false
}


resource "aws_iam_role_policy_attachment" "defaults_read" {
  for_each = {
    for aws_iam_policy in [
      module.default.aws_iam_policies["read"],
    ] : aws_iam_policy.name => aws_iam_policy.arn
  }

  role       = aws_iam_role.defaults["read"].name
  policy_arn = each.value
}


resource "aws_iam_role_policy_attachment" "defaults_readwrite" {
  for_each = {
    for aws_iam_policy in [
      module.default.aws_iam_policies["readwrite"],
    ] : aws_iam_policy.name => aws_iam_policy.arn
  }

  role       = aws_iam_role.defaults["readwrite"].name
  policy_arn = each.value
}
