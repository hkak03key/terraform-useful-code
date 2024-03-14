data "aws_iam_user" "hkak03key" {
  user_name = "hkak03key@gmail.com"
}


locals {
  admin_aws_iam_principals = [
    {
      name    = data.aws_iam_user.hkak03key.user_name
      id      = data.aws_iam_user.hkak03key.id
      arn     = data.aws_iam_user.hkak03key.arn
      user_id = data.aws_iam_user.hkak03key.user_id
    },
  ]
}
