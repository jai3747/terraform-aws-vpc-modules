# VPC
resource "aws_vpc" "main" {
  for_each = var.vpcs

  cidr_block           = each.value.cidr_block
  enable_dns_support   = lookup(each.value, "enable_dns_support", true)
  enable_dns_hostnames = lookup(each.value, "enable_dns_hostnames", true)

  tags = merge(
    var.default_tags,
    {
      Name = format("%s-%s-vpc", var.project_name, each.key)
    },
    lookup(each.value, "tags", {})
  )
}

# Internet Gateway - Only created when vpc.create_igw is true
resource "aws_internet_gateway" "igw" {
  for_each = {
    for vpc_key, vpc in var.vpcs : vpc_key => vpc
    if lookup(vpc, "create_igw", false)
  }

  vpc_id = aws_vpc.main[each.key].id

  tags = merge(
    var.default_tags,
    {
      Name = format("%s-%s-igw", var.project_name, each.key)
    }
  )
}

# Subnets
resource "aws_subnet" "subnet" {
  for_each = {
    for subnet in local.subnet_map : subnet.id => subnet
  }

  vpc_id                  = aws_vpc.main[each.value.vpc_key].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = merge(
    var.default_tags,
    {
      Name = format("%s-%s-%s-subnet", var.project_name, each.value.vpc_key, each.value.subnet_key)
    },
    each.value.tags
  )
}

# NAT Gateway - EIP allocation - Only one per VPC
resource "aws_eip" "nat" {
  for_each = local.nat_gateway_per_vpc
  
  domain = "vpc"

  tags = merge(
    var.default_tags,
    {
      Name = format("%s-%s-%s-nat-eip", var.project_name, each.key, each.value.subnet_key)
    }
  )
}

# NAT Gateway - Only one per VPC
resource "aws_nat_gateway" "nat" {
  for_each = local.nat_gateway_per_vpc

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.subnet[each.value.id].id

  tags = merge(
    var.default_tags,
    {
      Name = format("%s-%s-%s-nat-gateway", var.project_name, each.key, each.value.subnet_key)
    }
  )

  depends_on = [aws_internet_gateway.igw]
}

# Custom Route Tables for subnets - Only created for explicitly defined route tables
resource "aws_route_table" "subnet_rt" {
  for_each = local.custom_route_tables

  vpc_id = aws_vpc.main[each.value.vpc_key].id

  tags = merge(
    var.default_tags,
    {
      Name = format("%s-%s-%s-rt", var.project_name, each.value.vpc_key, each.value.subnet_key)
    }
  )
}

# Internet Gateway Routes - added to route tables where igw_attachment is true
resource "aws_route" "igw_route" {
  for_each = local.igw_routes

  route_table_id         = aws_route_table.subnet_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[each.value.vpc_key].id
}

# NAT Gateway Routes - added to route tables where nat_attachment is true
resource "aws_route" "nat_route" {
  for_each = local.nat_route_subnets

  route_table_id         = aws_route_table.subnet_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.value.vpc_key].id
}

# Route Table Associations
resource "aws_route_table_association" "rta" {
  for_each = {
    for subnet in local.subnet_map : subnet.id => subnet
    if subnet.create_custom_route_table || subnet.use_route_table_from != null
  }

  subnet_id = aws_subnet.subnet[each.key].id
  
  # Fix for the syntax error in conditional expression
  route_table_id = each.value.create_custom_route_table ? aws_route_table.subnet_rt[each.key].id : aws_route_table.subnet_rt["${each.value.vpc_key}:${each.value.use_route_table_from}"].id
}