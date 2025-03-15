# backend.tf
terraform {
  backend "s3" {
    bucket         = ""
    key            = "vpc-module/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = ""  
  }
}
