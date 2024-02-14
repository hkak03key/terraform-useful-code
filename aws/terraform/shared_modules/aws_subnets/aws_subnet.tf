locals {

  # cidr blockの割当て
  available_subnet_mask = tonumber(regex("[\\d.]+/(\\d+)", var.available_cidr_block)[0])
  cidr_blocks = cidrsubnets(
    var.available_cidr_block,
    [
      for subnet in var.subnet_configures :
      subnet.subnet_mask - local.available_subnet_mask
    ]...
  )

  subnet_configures = [
    for index, subnet in {
      for index in range(length(var.subnet_configures)) :
      index => var.subnet_configures[index]
    } :
    {
      subnet_group_name       = subnet.subnet_group_name
      az                      = subnet.az
      map_public_ip_on_launch = subnet.map_public_ip_on_launch
      cidr_block              = local.cidr_blocks[index]
    }
  ]

  # subnetごとに名前を付与するために subnet_group_name と az で group by していく
  subnet_group_names = distinct([
    for subnet in var.subnet_configures :
    subnet["subnet_group_name"]
  ])

  subnet_group_azs = {
    for subnet_group_name in local.subnet_group_names :
    subnet_group_name => distinct([
      for subnet in var.subnet_configures :
      subnet["az"] if subnet["subnet_group_name"] == subnet_group_name
    ])
  }

  subnet_configures_group_by = {
    for subnet_group_name in local.subnet_group_names :
    subnet_group_name => {
      for az in local.subnet_group_azs[subnet_group_name] :
      az => [
        for subnet in local.subnet_configures :
        subnet if subnet["subnet_group_name"] == subnet_group_name && subnet["az"] == az
      ]
    }
  }

  # # indexを付与
  # subnet_configures_group_by_with_index = {
  #   for subnet_group_name in local.subnet_group_names :
  #   subnet_group_name => [
  #     for az in local.subnet_group_azs[subnet_group_name] :
  #     {
  #       az => [
  #         for index in range(length(local.subnet_configures_group_by[subnet_group_name][az])) :
  #         merge(
  #           local.subnet_configures_group_by[subnet_group_name][az][index],
  #           { index = index }
  #         )
  #       ]
  #     }
  #   ]
  # }
}

resource "aws_subnet" "defaults" {
  for_each = merge(flatten([
    for subnet_group_name, subnet_group in local.subnet_configures_group_by :
    [
      for az, subnets in subnet_group :
      {
        for index in range(length(subnets)) :
        "${subnet_group_name}-${az}-${index}" => subnets[index]
      }
    ]
  ])...)

  vpc_id            = var.aws_vpc.id
  cidr_block        = each.value["cidr_block"]
  availability_zone = "${local.region}${each.value["az"]}"

  map_public_ip_on_launch = each.value["map_public_ip_on_launch"]

  tags = {
    Name = each.key
  }
}

locals {
  #  aws_subnets[subnet_group_name][az][index] でアクセスできるようにする
  aws_subnets = {
    for subnet_group_name in local.subnet_group_names :
    subnet_group_name => {
      for az in local.subnet_group_azs[subnet_group_name] :
      az => [
        for index in range(length(local.subnet_configures_group_by[subnet_group_name][az])) :
        aws_subnet.defaults["${subnet_group_name}-${az}-${index}"]
      ]
    }
  }
}

