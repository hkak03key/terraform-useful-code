locals {

  # cidr blockの割当て
  available_subnet_mask = tonumber(regex("[\\d.]+/(\\d+)", var.available_cidr_block)[0])
  cidr_blocks = cidrsubnets(
    var.available_cidr_block,
    [
      for subnet in var.subnets :
      subnet.subnet_mask - local.available_subnet_mask
    ]...
  )

  subnet_groups = {
    for subnet_group in var.subnet_groups :
    subnet_group.name => subnet_group
  }

  subnets = [
    for index, subnet in {
      for index in range(length(var.subnets)) :
      index => var.subnets[index]
    } :
    {
      subnet_group_name = subnet.subnet_group_name
      az                = subnet.az
      cidr_block        = local.cidr_blocks[index]
    }
  ]

  # subnetごとに名前を付与するために subnet_group_name と az で group by していく
  subnet_group_azs = {
    for subnet_group_name in keys(local.subnet_groups) :
    subnet_group_name => distinct([
      for subnet in var.subnets :
      subnet["az"] if subnet["subnet_group_name"] == subnet_group_name
    ])
  }

  subnets_group_by = {
    for subnet_group_name in keys(local.subnet_groups) :
    subnet_group_name => {
      for az in local.subnet_group_azs[subnet_group_name] :
      az => [
        for subnet in local.subnets :
        subnet if subnet["subnet_group_name"] == subnet_group_name && subnet["az"] == az
      ]
    }
  }
}

resource "aws_subnet" "defaults" {
  for_each = merge(flatten([
    for subnet_group_name, subnet_group in local.subnets_group_by :
    [
      for az, subnets in subnet_group :
      {
        for index in range(length(subnets)) :
        "${subnet_group_name}_${az}_${index}" => merge(
          subnets[index],
          {
            index = index
          }
        )
      }
    ]
  ])...)

  vpc_id            = var.aws_vpc.id
  cidr_block        = each.value["cidr_block"]
  availability_zone = "${local.region}${each.value["az"]}"

  map_public_ip_on_launch = local.subnet_groups[each.value["subnet_group_name"]].map_public_ip_on_launch

  tags = {
    Name = replace(
      join("-", [local.name_prefix, each.value["subnet_group_name"], each.value["az"], each.value["index"]]),
      "_",
      "-"
    )
  }
}

locals {
  #  aws_subnets[subnet_group_name][az][index] でアクセスできるようにする
  aws_subnets = {
    for subnet_group_name in keys(local.subnet_groups) :
    subnet_group_name => {
      for az in local.subnet_group_azs[subnet_group_name] :
      az => [
        for index in range(length(local.subnets_group_by[subnet_group_name][az])) :
        aws_subnet.defaults["${subnet_group_name}_${az}_${index}"]
      ]
    }
  }
}
