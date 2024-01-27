resource "aws_iam_role" "defaults" {
  for_each = toset([
    "admin_iam_policy_kms_policy",
    "admin_iam_policy_no_kms_policy",
    "admin_no_iam_policy_kms_policy",
    "admin_no_iam_policy_no_kms_policy",
    # "user_iam_policy_kms_policy", FIXME: impl iam policy
    # "user_iam_policy_no_kms_policy",
    "user_no_iam_policy_kms_policy",
    "user_no_iam_policy_no_kms_policy",
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


resource "aws_iam_role_policy_attachment" "admin_iam_policy_kms_policy" {
  for_each = {
    for aws_iam_policy in [
      data.aws_iam_policy.aws_managd_map["AdministratorAccess"],
    ] : aws_iam_policy.name => aws_iam_policy.arn
  }

  role       = aws_iam_role.defaults["admin_iam_policy_kms_policy"].name
  policy_arn = each.value
}


resource "aws_iam_role_policy_attachment" "admin_iam_policy_no_kms_policy" {
  for_each = {
    for aws_iam_policy in [
      data.aws_iam_policy.aws_managd_map["AdministratorAccess"],
    ] : aws_iam_policy.name => aws_iam_policy.arn
  }

  role       = aws_iam_role.defaults["admin_iam_policy_no_kms_policy"].name
  policy_arn = each.value
}


data "aws_iam_policy" "aws_managd_map" {
  for_each = toset([
    "AdministratorAccess",
  ])

  arn = "arn:aws:iam::aws:policy/${each.key}"
}
