

# Basic settings
region       = "ap-south-1"
project_name = "eks-network"


# VPC configurations
vpcs = {
  ###############################################
  # EKS VPC for Kubernetes Cluster
  ###############################################
  "eks-vpc" = {
    cidr_block           = "10.1.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    create_igw           = true
    create_nat           = true
    tags = {
      Environment = "Development"
      Tier        = "Kubernetes"
    }

    subnets = {
      # Public subnets for ALB and Load Balancers
      "eks-public-subnet-a" = {
        cidr_block              = "10.1.1.0/24"
        availability_zone       = "ap-south-1a"
        map_public_ip_on_launch = true
        igw_attachment          = true
        nat_attachment          = false
        create_custom_route_table = true
        tags = {
          Type = "Public"
          AZ   = "a"
        }
      },
      
      "eks-public-subnet-b" = {
        cidr_block              = "10.1.2.0/24"
        availability_zone       = "ap-south-1b"
        map_public_ip_on_launch = true
        igw_attachment          = true
        nat_attachment          = false
        create_custom_route_table = true
        tags = {
          Type = "Public"
          AZ   = "b"
        }
      },

      # Private subnets for EKS worker nodes
      "eks-private-subnet-a" = {
        cidr_block             = "10.1.10.0/24"
        availability_zone      = "ap-south-1a"
        nat_attachment         = true
        create_custom_route_table = true
        tags = {
          Type = "Private"
          AZ   = "a"
          Tier = "EKS Nodes"
        }
      },

      "eks-private-subnet-b" = {
        cidr_block             = "10.1.11.0/24"
        availability_zone      = "ap-south-1b"
        nat_attachment         = true
        create_custom_route_table = true
        tags = {
          Type = "Private"
          AZ   = "b"
          Tier = "EKS Nodes"
        }
      },
    }
  }
}
