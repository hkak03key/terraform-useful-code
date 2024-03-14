resource "aws_iam_role" "default" {
  name = local.long_name_prefix

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = var.aws_iam_openid_connect_provider.arn
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:${var.github_repository_name}:*"
          }
        }
      },
    ]
  })

  tags = {
    Name   = local.long_name_prefix
    module = path.module
  }
}


resource "aws_iam_role_policy_attachment" "these" {
  for_each = {
    for v in var.aws_iam_policies : v.name => v.arn
  }

  role       = aws_iam_role.default.name
  policy_arn = each.value
}
