resource "aws_network_interface" "defaults" {
  for_each = {
    no_attached = null
    ingress     = [module.ingress.aws_security_group.id]
    egress      = [module.egress.aws_security_group.id]

  }
  subnet_id = aws_subnet.default.id

  security_groups = each.value
}


resource "aws_ec2_network_insights_path" "defaults" {
  for_each = {
    from_no_attached_to_ingress = {
      source      = aws_network_interface.defaults["no_attached"].id
      destination = aws_network_interface.defaults["ingress"].id
    }
    from_egress_to_ingress = {
      source      = aws_network_interface.defaults["egress"].id
      destination = aws_network_interface.defaults["ingress"].id
    }
  }

  source      = each.value.source
  destination = each.value.destination
  protocol    = "tcp"
}
