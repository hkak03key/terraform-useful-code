data "aws_caller_identity" "default" {}

data "aws_region" "default" {}

locals {
  #======================
  # aws情報
  aws_account_id = data.aws_caller_identity.default.account_id
  region         = data.aws_region.default.name
}
