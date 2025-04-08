# backend.tf
terraform {
  backend "s3" {
    bucket         = "aws-config-poc-jc"
    key            = "vpc-module/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true

  }
}
