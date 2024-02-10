resource "aws_dynamodb_table" "default" {
  name         = local.name_prefix
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}
