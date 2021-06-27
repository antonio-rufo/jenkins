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
    key     = "terraform.jenkins-compute.tfstate"
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

# Get 000base layer outpouts
data "terraform_remote_state" "_data" {
  backend = "s3"

  config = {
    bucket  = "XXXXXXXXXXXX-build-state-bucket-jenkins-ec2"
    key     = "terraform.jenkins-data.tfstate"
    region  = "XXXXXXXXXXXX"
    encrypt = "true"
  }
}

locals {
  vpc_id          = data.terraform_remote_state._base.outputs.vpc_id
  vpc_cidr_block  = data.terraform_remote_state._base.outputs.vpc_cidr_block
  private_subnets = data.terraform_remote_state._base.outputs.private_subnets
  public_subnets  = data.terraform_remote_state._base.outputs.public_subnets
  efs_dns_name    = data.terraform_remote_state._data.outputs.efs_dns_name
  tags = {
    Terraform   = "True",
    Environment = var.environment
  }
  asg_tags = [{
    key                 = "Name"
    value               = "jenkins"
    propagate_at_launch = true
    },
    {
      key                 = "ManagedBy"
      value               = "Terraform"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    }
  ]
}

###############################################################################
# Resources - ALB SG
###############################################################################
module "jenkins-alb-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"

  name        = "jenkins-alb-sg"
  description = "Security group for access to Jenkins endpoint"
  vpc_id      = local.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]
}

###############################################################################
# Resources - EC2 SG
###############################################################################
module "jenkins-ec2-sg" {
  depends_on = [module.jenkins-alb-sg]

  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"

  name        = "jenkins-sg"
  description = "Security group for Jenkins host"
  vpc_id      = local.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = 6
      description              = "Jenkins ALB"
      source_security_group_id = module.jenkins-alb-sg.this_security_group_id
    },
  ]

  egress_rules = ["all-all"]
}

###############################################################################
# Role, Profile and attachment
###############################################################################
data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = var.principal_type
      identifiers = var.principal_identifiers
    }
  }
}

resource "aws_iam_role" "this" {
  name                  = var.role_name != null ? var.role_name : null
  name_prefix           = var.name_prefix != null ? substr(var.name_prefix, 0, 22) : null
  assume_role_policy    = var.assume_role_policy == "" ? data.aws_iam_policy_document.this.json : var.assume_role_policy
  force_detach_policies = var.force_detach_policies
  path                  = var.path
  description           = var.description
}

resource "aws_iam_instance_profile" "this" {
  depends_on = [aws_iam_role.this]

  name        = var.role_name != null ? var.role_name : null
  name_prefix = var.name_prefix != null ? substr(var.name_prefix, 0, 22) : null
  path        = var.path
  role        = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "this" {
  count = length(var.policy_arn)

  role       = aws_iam_role.this.name
  policy_arn = var.policy_arn[count.index]
}

###############################################################################
# Find latest Amazon Linux AMI
###############################################################################
data "aws_ami" "latest_amazon_linux_ami" {
  most_recent = true

  #
  # 137112412989 - AWS
  # Beware of using anything other than this
  #
  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

###############################################################################
# Render userdata bootstrap file
###############################################################################
data "template_file" "user_data" {
  template = file("${path.module}/userdata.sh")

  vars = {
    appliedhostname         = var.hostname_prefix
    domain_name             = var.domain_name
    environment             = var.environment
    efs_dnsname             = local.efs_dns_name
    supplementary_user_data = var.supplementary_user_data
  }
}

###############################################################################
# Launch Config
###############################################################################
resource "aws_launch_configuration" "jenkins" {
  name_prefix          = "terraform-jenkins-lc-"
  image_id             = data.aws_ami.latest_amazon_linux_ami.id
  instance_type        = var.instance_type
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.this.name
  security_groups      = [module.jenkins-ec2-sg.this_security_group_id]
  enable_monitoring    = var.enable_monitoring
  user_data            = var.custom_userdata != "" ? var.custom_userdata : data.template_file.user_data.rendered

  # Setup root block device
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
    encrypted   = var.encrypted
  }

  # Create before destroy
  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################
# Jenkins Auto-Scaling Group
###############################################################################
resource "aws_autoscaling_group" "jenkins" {
  depends_on = [aws_launch_configuration.jenkins]

  name                      = "${var.environment}_jenkins_asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  launch_configuration      = aws_launch_configuration.jenkins.name
  vpc_zone_identifier       = [local.private_subnets[0], local.private_subnets[1]]
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }

  dynamic "tag" {
    for_each = local.asg_tags
    content {
      key                 = tag.value["key"]
      value               = tag.value["value"]
      propagate_at_launch = tag.value["propagate_at_launch"]
    }
  }
}

###############################################################################
# Create scheduled action to rebuild Jenkins host,
# ensuring Jenkins is updated on a schedule.
###############################################################################
resource "aws_autoscaling_schedule" "scale_down" {
  count                  = var.autoscaling_schedule_create != 0 ? 1 : 0
  scheduled_action_name  = "scale_down"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = var.scale_down_cron
  autoscaling_group_name = aws_autoscaling_group.jenkins.name
}

resource "aws_autoscaling_schedule" "scale_up" {
  count                  = var.autoscaling_schedule_create != 0 ? 1 : 0
  scheduled_action_name  = "scale_up"
  min_size               = 1
  max_size               = 1
  desired_capacity       = 1
  recurrence             = var.scale_up_cron
  autoscaling_group_name = aws_autoscaling_group.jenkins.name
}

###############################################################################
# Jenkins ALB
###############################################################################
resource "aws_lb" "jenkins" {
  # only hyphens are allowed in name
  name = "${var.environment}-jenkins-alb"

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  internal                         = var.internal
  load_balancer_type               = "application"
  security_groups                  = [module.jenkins-alb-sg.this_security_group_id]
  subnets                          = local.public_subnets

  enable_deletion_protection = var.enable_deletion_protection

  tags = local.tags
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "jenkins-${var.environment}-tg"
  port     = var.svc_port
  protocol = var.target_group_protocol
  vpc_id   = local.vpc_id

  health_check {
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.timeout
    interval            = var.interval
    matcher             = var.success_codes

    path = var.target_group_path
    port = var.target_group_port
  }
}

resource "aws_lb_listener" "l1_alb_listener" {
  count             = var.http_listener_required ? 1 : 0
  load_balancer_arn = aws_lb.jenkins.arn
  port              = var.listener1_alb_listener_port
  protocol          = var.listener1_alb_listener_protocol

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "alb_listener" {
  depends_on = [aws_autoscaling_group.jenkins]

  load_balancer_arn = aws_lb.jenkins.arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol
  certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    type             = "forward"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  depends_on = [aws_autoscaling_group.jenkins]

  autoscaling_group_name = aws_autoscaling_group.jenkins.id
  alb_target_group_arn   = aws_lb_target_group.alb_target_group.arn
}

###############################################################################
# Route 53 entry for the ALB
###############################################################################
resource "aws_route53_record" "alb" {
  count = var.create_dns_record ? 1 : 0
  # Endpoint DNS record

  zone_id = var.zone_id
  name    = var.route53_endpoint_record
  type    = "CNAME"
  ttl     = "300"

  # matches up record N to instance N
  records = [aws_lb.jenkins.dns_name]
}
