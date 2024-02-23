resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.default.id

  # すべて遮断
  tags = {
    Name = replace(
      join("-", [local.name_prefix, "default"]),
      "_",
      "-"
    )
  }
}


resource "aws_security_group" "egress_to_all" {
  name = replace(
    join("-", [local.name_prefix, "egress_to_all"]),
    "_",
    "-"
  )

  description = "allow all egress traffic"
  vpc_id      = aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = replace(
      join("-", [local.name_prefix, "egress_to_all"]),
      "_",
      "-"
    )
  }
}
