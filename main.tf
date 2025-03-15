# main.tf

provider "aws" {
  region = var.region
  default_tags {
    tags = var.default_tags
  }
}

module "vpc" {
  source = "./modules"  
  region       = var.region
  project_name = var.project_name
  default_tags = var.default_tags
  vpcs         = var.vpcs
}