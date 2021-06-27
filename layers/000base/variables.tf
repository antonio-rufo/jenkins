###############################################################################
# Variables - Environment
###############################################################################
variable "aws_account_id" {
  description = "(Required) AWS Account ID."
}

variable "region" {
  description = "(Required) Region where resources will be created."
  default     = "ap-southeast-2"
}

variable "environment" {
  description = "(Optional) The name of the environment, e.g. Production, Development, etc."
  default     = "Development"
}
