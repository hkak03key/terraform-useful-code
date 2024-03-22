/* Resource */
resource "aws_cloudwatch_log_subscription_filter" "default" {
  name = replace(
    join("-", compact([local.name_prefix, "cw_logs_subscription"])),
    "_", "-"
  )

  role_arn       = aws_iam_role.cw_logs_subscription.arn
  log_group_name = aws_cloudwatch_log_group.default.name

  filter_pattern = ""

  destination_arn = aws_kinesis_firehose_delivery_stream.default.arn

  depends_on = [
    aws_iam_role_policy_attachment.cw_logs_subscription,
  ]
}


resource "aws_iam_role" "cw_logs_subscription" {
  name = replace(
    join("-", compact([local.name_prefix, "cw_logs_subscription"])),
    "_", "-"
  )
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "logs.amazonaws.com",
          ]
        }
        Condition = {
          StringLike = {
            "aws:SourceArn" : "arn:aws:logs:${local.region}:${local.aws_account_id}:*"
          }
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "cw_logs_subscription" {
  for_each = {
    for p in [
      aws_iam_policy.firehose_write,
    ] : p.name => p.arn
  }
  role       = aws_iam_role.cw_logs_subscription.id
  policy_arn = each.value
}
