/* Resource */
resource "aws_dynamodb_table" "default" {
  name         = local.name_prefix
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}


/* IAM Policy */
locals {
  _aws_iam_policy_dynamodb_readwrite = jsondecode(
    templatefile(
      "${local._system_info["aws_iam_policy_infos_dir"]}/dynamodb_readwrite.json.tftpl",
      {
        # iam policyに関する情報
        iam_policy_aws_account_id = local.aws_account_id
        # アクセスしたいリソースに関する情報
        resource_aws_account_id = local.aws_account_id
        resource_region         = local.region
        resource_name           = aws_dynamodb_table.default.name
      }
    )
  )
}


resource "aws_iam_policy" "dynamodb_readwrite" {
  name        = local._aws_iam_policy_dynamodb_readwrite["name"]
  path        = "/"
  description = ""

  policy = jsonencode(local._aws_iam_policy_dynamodb_readwrite["policy"])
}
