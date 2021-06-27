###############################################################################
# Variables - Environment
###############################################################################
variable "aws_account_id" {
  type        = string
  description = "(Required) AWS Account ID."
}

variable "region" {
  type        = string
  description = "(Required) Region where resources will be created."
  default     = "ap-southeast-2"
}

variable "environment" {
  type        = string
  description = "(Optional) The name of the environment, e.g. Production, Development, etc."
  default     = "Development"
}

###############################################################################
# Variables - Environment
###############################################################################
variable "deletion_window_in_days" {
  type        = number
  description = "Number of days before permanent removal."
  default     = "30"
}

variable "enable_key_rotation" {
  type        = bool
  description = "KMS key rotation."
  default     = true
}

variable "efs_encrypted" {
  type        = bool
  description = "Encrypt the EFS share."
  default     = true
}

variable "performance_mode" {
  type        = string
  description = "EFS performance mode.https://docs.aws.amazon.com/efs/latest/ug/performance.html"
  default     = "generalPurpose"
}
