resource "aws_iam_role" "defaults" {
  for_each = toset([
    "read",
    "readwrite",
    "not_attached",
    "external", # module内で権限付与をしていない
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


data "aws_iam_policy" "managed" {
  for_each = toset([
    "AdministratorAccess",
  ])

  arn = "arn:aws:iam::aws:policy/${each.key}"
}


resource "aws_iam_role_policy_attachment" "external" {
  for_each = {
    for aws_iam_policy in [
      data.aws_iam_policy.managed["AdministratorAccess"],
    ] : aws_iam_policy.name => aws_iam_policy.arn
  }

  role       = aws_iam_role.defaults["external"].name
  policy_arn = each.value
}
