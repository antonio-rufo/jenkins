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
    key     = "terraform.jenkins-data.tfstate"
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

# Get 000base layer outpouts
data "terraform_remote_state" "_base" {
  backend = "s3"

  config = {
    bucket  = "XXXXXXXXXXXX-build-state-bucket-jenkins-ec2"
    key     = "terraform.jenkins-base.tfstate"
    region  = "XXXXXXXXXXXX"
    encrypt = "true"
  }
}

locals {
  vpc_id          = data.terraform_remote_state._base.outputs.vpc_id
  vpc_cidr_block  = data.terraform_remote_state._base.outputs.vpc_cidr_block
  private_subnets = data.terraform_remote_state._base.outputs.private_subnets
  public_subnets  = data.terraform_remote_state._base.outputs.public_subnets
  tags = {
    Terraform   = "True",
    Environment = var.environment
  }
}

###############################################################################
# Resources - EFS SG
###############################################################################
module "jenkins-efs-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"

  name        = "jenkins-efs-sg"
  description = "Security group for Jenkins EFS"
  vpc_id      = local.vpc_id

  ingress_cidr_blocks = [local.vpc_cidr_block]
  ingress_rules       = ["nfs-tcp"]
  egress_rules        = ["all-all"]
}

###############################################################################
# KMS Key for EFS
###############################################################################
resource "aws_kms_key" "efskey" {
  description             = "This key is used to encrypt EFS, used by Jenkins, in ${var.environment}"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
}

###############################################################################
# Create KMS Alias
###############################################################################
resource "aws_kms_alias" "efs" {
  name          = "alias/efs-jenkins-${var.environment}"
  target_key_id = aws_kms_key.efskey.key_id
}

###############################################################################
# EFS FileSystem
###############################################################################
resource "aws_efs_file_system" "this" {
  depends_on = [aws_kms_key.efskey]

  encrypted        = var.efs_encrypted
  performance_mode = var.performance_mode
  kms_key_id       = aws_kms_key.efskey.arn

  tags = local.tags
}

###############################################################################
# Mount points
###############################################################################
resource "aws_efs_mount_target" "private_subnet_a" {
  depends_on = [aws_efs_file_system.this]

  file_system_id  = aws_efs_file_system.this.id
  security_groups = [module.jenkins-efs-sg.this_security_group_id]
  subnet_id       = local.private_subnets[0]
}

resource "aws_efs_mount_target" "private_subnet_b" {
  depends_on = [aws_efs_file_system.this]

  file_system_id  = aws_efs_file_system.this.id
  security_groups = [module.jenkins-efs-sg.this_security_group_id]
  subnet_id       = local.private_subnets[1]
}
