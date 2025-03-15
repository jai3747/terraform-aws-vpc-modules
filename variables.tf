# variables.tf
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "myproject"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Terraform   = "true"
  }
}

variable "vpcs" {
  description = "Map of VPC configurations"
  type = map(object({
    cidr_block           = string
    enable_dns_support   = optional(bool, true)
    enable_dns_hostnames = optional(bool, true)
    create_igw           = optional(bool, false)
    create_nat           = optional(bool, false)
    tags                 = optional(map(string), {})
    
    subnets = map(object({
      cidr_block              = string
      availability_zone       = string
      map_public_ip_on_launch = optional(bool, false)
      igw_attachment          = optional(bool, false)
      nat_attachment          = optional(bool, false)
      create_custom_route_table = optional(bool, false)
      use_route_table_from    = optional(string)
      tags                    = optional(map(string), {})
    }))
  }))
}

