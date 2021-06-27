###############################################################################
# Outputs - VPC
###############################################################################
output "private_subnets" {
  description = "A list of private subnets inside the VPC."
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "A list of public subnets inside the VPC."
  value       = module.vpc.public_subnets
}

output "vpc_id" {
  description = "A list of public subnets inside the VPC."
  value       = module.vpc.vpc_id
}
