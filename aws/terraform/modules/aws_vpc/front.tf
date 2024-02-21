resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = local.name_prefix
  }
}


resource "aws_route_table" "front" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = replace(
      join("-", [local.name_prefix, "front"]),
      "_",
      "-"
    )
  }
}


resource "aws_route" "front_internet_gateway" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.front.id
  gateway_id             = aws_internet_gateway.default.id
}


resource "aws_route_table_association" "fronts" {
  for_each = merge(flatten([
    for az in keys(module.aws_subnets.aws_subnets["front"]) :
    [
      for index in range(length(az)) :
      {
        "${az}_${index}" = module.aws_subnets.aws_subnets["front"][az][index]
      }
    ]
  ])...)
  subnet_id      = each.value.id
  route_table_id = aws_route_table.front.id
}
