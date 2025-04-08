# terraform.tfvars
# Comprehensive configuration for VPC module with all options demonstrated

# Basic settings
region       = "ap-south-1"
project_name = "mmfssl"

# Tags applied to all resources
default_tags = {
  Environment = "Development"
  Terraform   = "true"
  Project     = "DynamicVPC"
  Owner       = "DevOps"
  CostCenter  = "123456"
}

# VPC configurations
vpcs = {
  ###############################################
  # Production VPC with full networking setup
  ###############################################
  "prod" = {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    create_igw           = true
    create_nat           = true
    tags = {
      Environment = "Production"
      Tier        = "Network"
    }
    
    subnets = {
      # Public subnet in AZ-a with NAT Gateway
      "public-a" = {
        cidr_block              = "10.0.1.0/24"
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
      
      # Public subnet in AZ-b with NAT Gateway (for high availability)
      "public-b" = {
        cidr_block              = "10.0.2.0/24"
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
      
      # Public subnet in AZ-c - uses route table from public-a
      "public-c" = {
        cidr_block              = "10.0.3.0/24"
        availability_zone       = "ap-south-1c"
        map_public_ip_on_launch = true
        igw_attachment          = true
        nat_attachment          = false
        use_route_table_from    = "public-a"  # Share route table with public-a
        tags = {
          Type = "Public"
          AZ   = "c"
        }
      },
      
      # Private subnet in AZ-a with NAT gateway access
      "private-app-a" = {
        cidr_block             = "10.0.10.0/24"
        availability_zone      = "ap-south-1a"
        nat_attachment         = true
        create_custom_route_table = true
        tags = {
          Type = "Private"
          AZ   = "a"
          Tier = "Application"
        }
      },
      
      # Private subnet in AZ-b with NAT gateway access
      "private-app-b" = {
        cidr_block             = "10.0.11.0/24"
        availability_zone      = "ap-south-1b"
        nat_attachment         = true
        create_custom_route_table = true
        tags = {
          Type = "Private"
          AZ   = "b"
          Tier = "Application"
        }
      },
      
      # Private subnet in AZ-c that shares the route table with private-app-a
      "private-app-c" = {
        cidr_block             = "10.0.12.0/24"
        availability_zone      = "ap-south-1c"
        nat_attachment         = false
        use_route_table_from   = "private-app-a"  # Share route table
        tags = {
          Type = "Private"
          AZ   = "c"
          Tier = "Application"
        }
      },
      
      # Database subnet in AZ-a
      "private-db-a" = {
        cidr_block             = "10.0.20.0/24"
        availability_zone      = "ap-south-1a"
        create_custom_route_table = true
        nat_attachment         = true
        tags = {
          Type = "Private"
          AZ   = "a"
          Tier = "Database"
        }
      },
      
      # Database subnet in AZ-b
      "private-db-b" = {
        cidr_block             = "10.0.21.0/24"
        availability_zone      = "ap-south-1b"
        nat_attachment         = false
        use_route_table_from   = "private-db-a"  # Share route table
        tags = {
          Type = "Private"
          AZ   = "b"
          Tier = "Database"
        }
      },
      
      # Database subnet in AZ-c
      "private-db-c" = {
        cidr_block             = "10.0.22.0/24"
        availability_zone      = "ap-south-1c"
        nat_attachment         = false
        use_route_table_from   = "private-db-a"  # Share route table
        tags = {
          Type = "Private"
          AZ   = "c"
          Tier = "Database"
        }
      }
    }
  },
  
  ###############################################
  # Dev/Test VPC with minimal networking setup
  ###############################################
  "dev" = {
    cidr_block           = "172.16.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    create_igw           = true
    create_nat           = true
    tags = {
      Environment = "Development"
    }
    
    subnets = {
      # Single public subnet for dev/test
      "public" = {
        cidr_block              = "172.16.1.0/24"
        availability_zone       = "ap-south-1a"
        map_public_ip_on_launch = true
        igw_attachment          = true
        nat_attachment          = false
        create_custom_route_table = true
        tags = {
          Type = "Public"
        }
      },
      
      # Single private subnet for dev/test
      "private" = {
        cidr_block             = "172.16.2.0/24"
        availability_zone      = "ap-south-1a"
        nat_attachment         = true
        create_custom_route_table = true
        tags = {
          Type = "Private"
        }
      }
    }
  },
  
  ###############################################
  # Isolated VPC with no internet access
  ###############################################
  "isolated" = {
    cidr_block           = "192.168.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = false
    create_igw           = false  # No IGW, fully isolated
    create_nat           = false  # No NAT for isolated VPC
    tags = {
      Environment = "Isolated"
      Security    = "High"
    }
    
    subnets = {
      # First isolated subnet
      "subnet-1" = {
        cidr_block        = "192.168.1.0/24"
        availability_zone = "ap-south-1a"
        create_custom_route_table = true
        nat_attachment    = false
        tags = {
          Type = "Isolated"
          AZ   = "a"
        }
      },
      
      # Second isolated subnet
      "subnet-2" = {
        cidr_block        = "192.168.2.0/24"
        availability_zone = "ap-south-1b"
        nat_attachment    = false
        use_route_table_from = "subnet-1"  # Share route table
        tags = {
          Type = "Isolated"
          AZ   = "b"
        }
      }
    }
  }
}
