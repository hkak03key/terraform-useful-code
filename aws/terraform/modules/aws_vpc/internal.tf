resource "aws_network_acl" "internal" {
  vpc_id = aws_vpc.default.id

  dynamic "egress" {
    for_each = local.aws_subnets_flattened_each_groups["app"]
    content {
      rule_no    = 100 + index(local.aws_subnets_flattened_each_groups["app"], egress.value)
      protocol   = "-1"
      action     = "allow"
      cidr_block = egress.value.aws_subnet.cidr_block
      from_port  = 0
      to_port    = 0
    }
  }

  dynamic "ingress" {
    for_each = local.aws_subnets_flattened_each_groups["app"]
    content {
      rule_no    = 100 + index(local.aws_subnets_flattened_each_groups["app"], ingress.value)
      protocol   = "-1"
      action     = "allow"
      cidr_block = ingress.value.aws_subnet.cidr_block
      from_port  = 0
      to_port    = 0
    }
  }

  tags = {
    Name = replace(
      join("-", [local.name_prefix, "internal"]),
      "_",
      "-"
    )
  }
}


resource "aws_network_acl_association" "internal" {
  for_each = {
    for subnet in local.aws_subnets_flattened_each_groups["internal"] :
    "${subnet.az}_${subnet.index}" => subnet
  }

  network_acl_id = aws_network_acl.internal.id
  subnet_id      = each.value.aws_subnet.id
}
