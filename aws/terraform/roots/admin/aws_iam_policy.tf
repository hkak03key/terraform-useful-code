data "aws_iam_policy" "aws_managed" {
  for_each = toset([
    "ReadOnlyAccess",
  ])

  arn = "arn:aws:iam::aws:policy/${each.value}"
}
