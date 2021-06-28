###############################################################################
# Terraform main config
###############################################################################
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = "~> 3.41.0"
  }
  backend "s3" {
    bucket  = "XXXXXXXXXXXX-build-state-bucket-jenkins-ec2"
    key     = "terraform.jenkins-base.tfstate"
    region  = "XXXXXXXXXXXX"
    encrypt = "true"
  }
}

###############################################################################
# Providers
###############################################################################
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

locals {
  tags = {
    Terraform   = "True",
    Environment = var.environment
  }
}

###############################################################################
# Resources - VPC
###############################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.65.0"

  name = "Jenkins VPC"
  cidr = "172.18.0.0/16"

  azs             = ["ap-southeast-2a", "ap-southeast-2b"]
  private_subnets = ["172.18.0.0/19", "172.18.32.0/19"]
  public_subnets  = ["172.18.128.0/19", "172.18.160.0/19"]

  enable_nat_gateway     = true
  enable_dns_hostnames   = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  tags = local.tags
}
