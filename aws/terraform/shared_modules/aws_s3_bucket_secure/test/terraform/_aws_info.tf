data "aws_caller_identity" "default" {}

data "aws_region" "default" {}

locals {
  #======================
  # aws情報
  aws_account_id = data.aws_caller_identity.default.account_id
  region         = data.aws_region.default.name

  aws_caller_identity = {
    account_id = data.aws_caller_identity.default.account_id
    name       = replace(data.aws_caller_identity.default.arn, "/^arn:aws:(iam|sts):[^:]*:[0-9]{12}:(user|role|assumed-role)/([^/]*)/", "$3")
    arn        = replace(data.aws_caller_identity.default.arn, "/^arn:aws:sts:[^:]*:([0-9]{12}):assumed-role/([^/]*)/.*/", "arn:aws:iam::$1:role/$2")
    user_id    = replace(data.aws_caller_identity.default.user_id, "/^([^:]+):.*/", "$1")
  }
}
