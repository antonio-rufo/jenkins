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
# Variables - Jenkins IAM Role
###############################################################################
variable "role_name" {
  type        = string
  description = "The IAM Role name. Conflicts with name_prefix. Choose either."
  default     = null
}

variable "name_prefix" {
  type        = string
  description = "The IAM Role name prefix. Conflicts with name. Choose either."
  default     = null
}

variable "assume_role_policy" {
  description = "Assume Role Policy."
  default     = ""
}

variable "force_detach_policies" {
  type        = bool
  description = "Allow policy / policies to be forcibly detached."
  default     = false
}

variable "path" {
  description = "IAM Role path."
  default     = "/"
}

variable "description" {
  description = "IAM Role description."
  default     = "Managed by Terraform."
}

variable "policy_arn" {
  description = "List of policy ARNs to attached to the role."
  type        = list(string)
}

variable "principal_type" {
  type        = string
  description = "Principal type for trust identity."
  default     = "Service"
}

variable "principal_identifiers" {
  type        = list(string)
  description = "Principal identifier for trust identity."
  default     = ["ec2.amazonaws.com"]
}

###############################################################################
# Variables - Jenkins ALB
###############################################################################
variable "internal" {
  type        = bool
  description = "Is the ALB internal?"
  default     = false
}

variable "enable_cross_zone_load_balancing" {
  type        = bool
  description = "Enable / Disable cross zone load balancing."
  default     = false
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Enable / Disable deletion protection for the ALB."
  default     = false
}

variable "svc_port" {
  type        = number
  description = "Service port: The port on which targets receive traffic."
  default     = 8080
}

variable "target_group_protocol" {
  type        = string
  description = "The protocol to use to connect to the target."
  default     = "HTTP"
}

variable "healthy_threshold" {
  type        = number
  description = "ALB healthy count."
  default     = 2
}

variable "unhealthy_threshold" {
  type        = number
  description = "ALB unhealthy count."
  default     = 10
}

variable "timeout" {
  type        = number
  description = "ALB timeout value."
  default     = 5
}

variable "interval" {
  type        = number
  description = "ALB health check interval."
  default     = 20
}

variable "success_codes" {
  description = "Success Codes for the Target Group Health Checks. Default is 200 ( OK )."
  type        = string
  default     = "200"
}

variable "target_group_path" {
  type        = string
  description = "Health check request path."
  default     = "/"
}

variable "target_group_port" {
  type        = number
  description = "The port to use to connect with the target."
  default     = "8080"
}

variable "http_listener_required" {
  type        = bool
  description = "Enables / Disables creating HTTP listener. Listener auto redirects to HTTPS."
  default     = true
}

variable "listener1_alb_listener_port" {
  type        = number
  description = "HTTP listener port."
  default     = 80
}

variable "listener1_alb_listener_protocol" {
  type        = string
  description = "HTTP listener protocol."
  default     = "HTTP"
}

variable "alb_listener_port" {
  type        = number
  description = "ALB listener port."
  default     = "443"
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the SSL certificate to use."
}

variable "alb_listener_protocol" {
  type        = string
  description = "ALB listener protocol."
  default     = "HTTPS"
}

###############################################################################
# Variables - Jenkins Launch Configuration
###############################################################################
variable "instance_type" {
  type        = string
  description = "ec2 instance type."
  default     = "t3a.medium"
}

variable "key_name" {
  type        = string
  description = "ec2 key pair use."
}

variable "enable_monitoring" {
  type        = bool
  description = "AutoScaling - enables/disables detailed monitoring."
  default     = "false"
}

variable "custom_userdata" {
  description = "Set custom userdata."
  type        = string
  default     = ""
}

variable "volume_size" {
  type        = number
  description = "ec2 volume size."
  default     = 30
}

variable "volume_type" {
  type        = string
  description = "ec2 volume type."
  default     = "gp2"
}

variable "encrypted" {
  type        = bool
  description = "Encryption of volumes."
  default     = true
}

variable "hostname_prefix" {
  type        = string
  description = "Hostname prefix for the Jenkins server."
  default     = "jenkins"
}

variable "domain_name" {
  type        = string
  description = "Domain Name."
}

variable "supplementary_user_data" {
  type        = string
  description = "Supplementary shell script commands for adding to user data.Runs at the end of userdata."
  default     = "#supplementary_user_data"
}

variable "autoscaling_schedule_create" {
  type        = number
  description = "Allows for disabling of scheduled actions on ASG. Enabled by default."
  default     = 1
}

variable "scale_down_cron" {
  type        = string
  description = "The time when the recurring scale down action start. Cron format."
  default     = "0 0 * * SUN"
}

variable "scale_up_cron" {
  type        = string
  description = "The time when the recurring scale up action start.Cron format."
  default     = "30 0 * * SUN"
}

###############################################################################
# Variables - Autoscaling Group
###############################################################################
variable "max_size" {
  type        = number
  description = "AutoScaling Group max size."
  default     = 1
}

variable "min_size" {
  type        = number
  description = "AutoScaling Group min size."
  default     = 1
}

variable "desired_capacity" {
  type        = number
  description = "AutoScaling Group desired capacity."
  default     = 1
}

variable "health_check_grace_period" {
  type        = number
  description = "AutoScaling health check grace period."
  default     = 180
}

variable "health_check_type" {
  type        = string
  description = "AutoScaling health check type. EC2 or ELB."
  default     = "ELB"
}

###############################################################################
# Variables - Route53
###############################################################################
variable "create_dns_record" {
  description = "Create friendly DNS CNAME."
  type        = bool
  default     = true
}

variable "zone_id" {
  type        = string
  description = "Route 53 zone id."
  default     = null
}

variable "route53_endpoint_record" {
  type        = string
  description = "Route 53 endpoint name. Creates route53_endpoint_record."
  default     = "jenkins"
}
