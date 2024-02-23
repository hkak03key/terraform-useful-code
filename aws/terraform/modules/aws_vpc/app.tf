resource "aws_route_table" "apps" {
  # az毎に作る
  for_each = toset(keys(module.aws_subnets.aws_subnets["app"]))

  vpc_id = aws_vpc.default.id

  tags = {
    Name = replace(
      join("-", [local.name_prefix, "apps", each.key]),
      "_",
      "-"
    )
  }
}


resource "aws_route" "app_nat_gateways" {
  for_each = aws_route_table.apps

  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = each.value.id
  nat_gateway_id = (
    var.nat["az"] == "ALL" ?
    aws_nat_gateway.defaults[each.key].id :
    aws_nat_gateway.defaults[var.nat["az"]].id
  )
}


resource "aws_route_table_association" "apps" {
  # subnet毎に作る
  for_each = {
    for subnet in local.aws_subnets_flattened_each_groups["app"] :
    "${subnet.az}_${subnet.index}" => subnet
  }

  subnet_id      = each.value["aws_subnet"].id
  route_table_id = aws_route_table.apps[each.value["az"]].id
}
