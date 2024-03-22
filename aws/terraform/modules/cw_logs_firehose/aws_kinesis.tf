resource "aws_kinesis_firehose_delivery_stream" "default" {
  name = replace(
    join("-", compact([local.name_prefix])),
    "_", "-"
  )
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = module.aws_s3_bucket_core.aws_s3_bucket.arn

    buffering_interval = 10 # for experimentation
  }
}


resource "aws_iam_role" "firehose" {
  name = replace(
    join("-", compact([local.name_prefix, "firehose"])),
    "_", "-"
  )

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "firehose" {
  for_each = {
    for p in [
      module.aws_s3_bucket_core.aws_iam_policies["readwrite"],
    ] : p.name => p.arn
  }
  role       = aws_iam_role.firehose.id
  policy_arn = each.value
}
