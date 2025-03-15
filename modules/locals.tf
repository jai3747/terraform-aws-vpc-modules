locals {
  # Flatten subnet maps for easier iteration
  subnet_map = flatten([
    for vpc_key, vpc in var.vpcs : [
      for subnet_key, subnet in vpc.subnets : {
        id                      = "${vpc_key}:${subnet_key}"
        vpc_key                 = vpc_key
        subnet_key              = subnet_key
        cidr_block              = subnet.cidr_block
        availability_zone       = subnet.availability_zone
        map_public_ip_on_launch = lookup(subnet, "map_public_ip_on_launch", false)
        igw_attachment          = lookup(subnet, "igw_attachment", false)
        nat_attachment          = lookup(subnet, "nat_attachment", false)
        create_custom_route_table = lookup(subnet, "create_custom_route_table", false)
        use_route_table_from    = lookup(subnet, "use_route_table_from", null)
        tags                    = lookup(subnet, "tags", {})
      }
    ]
  ])
  
  # Find the first public subnet for each VPC (for NAT gateway placement)
  public_subnets_per_vpc = {
    for vpc_key, vpc in var.vpcs : vpc_key => [
      for subnet in local.subnet_map : subnet
      if subnet.vpc_key == vpc_key && subnet.igw_attachment
    ][0] if lookup(vpc, "create_nat", false) && lookup(vpc, "create_igw", false) && 
    length([for subnet in local.subnet_map : subnet if subnet.vpc_key == vpc_key && subnet.igw_attachment]) > 0
  }
  
  # Create a map for NAT gateways - one per VPC
  nat_gateway_per_vpc = {
    for vpc_key, subnet in local.public_subnets_per_vpc : vpc_key => subnet
  }
  
  # Create map of private subnets requiring NAT gateway routes
  nat_route_subnets = {
    for subnet in local.subnet_map : subnet.id => subnet
    if subnet.nat_attachment && contains(keys(local.nat_gateway_per_vpc), subnet.vpc_key)
  }
  
  # Create map of subnets with custom route tables - only explicitly defined ones
  custom_route_tables = {
    for subnet in local.subnet_map : subnet.id => subnet
    if subnet.create_custom_route_table
  }
  
  # Create map of subnets with IGW routes
  igw_routes = {
    for subnet in local.subnet_map : subnet.id => subnet
    if subnet.igw_attachment && lookup(var.vpcs[subnet.vpc_key], "create_igw", false) && subnet.create_custom_route_table
  }
}

