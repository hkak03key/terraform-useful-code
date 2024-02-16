resource "aws_security_group" "default" {
  name_prefix = local.name_prefix
  vpc_id      = var.aws_vpc.id

  tags = {
    Name                         = local.name_prefix
    aws_security_group_connector = "true"
  }
}


resource "aws_vpc_security_group_egress_rule" "defaults" {
  for_each = {
    for sg in var.egress_aws_security_groups :
    sg.tags["Name"] => sg
  }

  security_group_id = aws_security_group.default.id

  referenced_security_group_id = each.value.id
  ip_protocol                  = "-1"
}


resource "aws_vpc_security_group_ingress_rule" "defaults" {
  for_each = {
    for sg in var.ingress_aws_security_groups :
    sg.tags["Name"] => sg
  }

  security_group_id = aws_security_group.default.id

  referenced_security_group_id = each.value.id
  ip_protocol                  = "-1"
}
