# outputs.tf
output "vpc_ids" {
  description = "Map of VPC IDs"
  value = {
    for k, v in aws_vpc.main : k => v.id
  }
}

output "subnet_ids" {
  description = "Map of subnet IDs"
  value = {
    for k, v in aws_subnet.subnet : k => v.id
  }
}

output "igw_ids" {
  description = "Map of Internet Gateway IDs"
  value = {
    for k, v in aws_internet_gateway.igw : k => v.id
  }
}

output "nat_gateway_ids" {
  description = "Map of NAT Gateway IDs"
  value = {
    for k, v in aws_nat_gateway.nat : k => v.id
  }
}

output "route_table_ids" {
  description = "Map of Route Table IDs"
  value = {
    for k, v in aws_route_table.subnet_rt : k => v.id
  }
}