module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=2e417ad0ce830893127476436179ef483485ae84"

  azs = ["eu-central-1a", "eu-central-1b"]

  cidr                                 = "10.0.0.0/16"
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  enable_flow_log    = true
  enable_nat_gateway = true

  flow_log_cloudwatch_log_group_class             = "INFREQUENT_ACCESS"
  flow_log_cloudwatch_log_group_retention_in_days = 30
  flow_log_cloudwatch_log_group_skip_destroy      = true
  flow_log_destination_type                       = "cloudwatch-logs"
  flow_log_max_aggregation_interval               = 60
  flow_log_file_format                            = "plain-text"
  flow_log_traffic_type                           = "ALL"
  flow_log_per_hour_partition                     = true

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false
  manage_default_vpc            = false

  name = "${var.prefix}-vpc"

  private_subnets = [
    "${cidrsubnet(module.vpc.vpc_cidr_block, 8, 1)}",
    "${cidrsubnet(module.vpc.vpc_cidr_block, 8, 2)}"
  ]
  private_subnet_names = [
    "${var.prefix}-private-subnet-1",
    "${var.prefix}-private-subnet-2"
  ]
  private_subnet_suffix = ""

  public_subnets = [
    "${cidrsubnet(module.vpc.vpc_cidr_block, 8, 3)}",
    "${cidrsubnet(module.vpc.vpc_cidr_block, 8, 4)}"
  ]
  public_subnet_names = [
    "${var.prefix}-public-subnet-1",
    "${var.prefix}-public-subnet-2"
  ]
  public_subnet_suffix = ""

  single_nat_gateway = true

  vpc_flow_log_iam_policy_name = "${var.prefix}-vpc-flow-log-iam-policy"
  vpc_flow_log_iam_role_name   = "${var.prefix}-vpc-flow-log-iam-role"
}

module "ec2_security_group" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=20e107f1658bc5c8b23efce2e17406e74e6cbeae"

  name        = "${var.prefix}-ec2-sg"
  description = "Security group for NextCloud EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = [
    "http-80-tcp",
    "all-icmp",
    "https-443-tcp",
    "smtps-465-tcp",
    "custom-8080-tcp"
  ]
  egress_rules = ["all-all"]
}

resource "aws_iam_policy" "ec2_s3_access" {
  name        = "${var.prefix}-ec2-s3-access"
  description = "Policy for EC2 instances to interact with S3 buckets"
  policy      = templatefile("${path.module}/templates/access_landing_bucket.tftpl", {
    landing_bucket = module.s3-bucket-landing.s3_bucket_arn
  })
}

module "ec2" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git?ref=4f8387d0925510a83ee3cb88c541beb77ce4bad6"
  count  = 1

  ami = "ami-0e872aee57663ae2d" # Ubuntu Server 24.04 LTS (HVM), SSD Volume Type

  create_iam_instance_profile = true

  iam_role_description = "Role for EC2 instances"
  iam_role_name        = "${var.prefix}-ec2-role"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    S3Landing = aws_iam_policy.ec2_s3_access.arn
  }
  instance_type = "t3.medium"

  monitoring = true

  name = "${var.prefix}-ec2"

  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 8
      volume_type           = "gp3"
    }
  ]

  subnet_id = module.vpc.private_subnets[0]

  user_data = fileexists("${path.module}/scripts/user_data/deploy_nextcloud.sh") ? file("${path.module}/scripts/user_data/deploy_nextcloud.sh") : null

  vpc_security_group_ids = [module.ec2_security_group.security_group_id]
}

resource "aws_acm_certificate" "cert" {
  certificate_body  = file("${path.module}/certs/dfr-tfm-nextcloud.duckdns.org.crt")
  certificate_chain = file("${path.module}/certs/dfr-tfm-nextcloud.duckdns.org.chain.crt")
  private_key       = file("${path.module}/certs/dfr-tfm-nextcloud.duckdns.org.key")

  lifecycle {
    create_before_destroy = true
  }
}

module "alb" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git?ref=ce3014eea6f44d5078b76ddc92f1cbe0df418cd2"

  access_logs = {
    bucket = "my-access-logs-bucket"
    prefix = "my-alb-logs"
  }

  enable_tls_version_and_cipher_suite_headers = true

  listeners = {
    http = {
      port               = 80
      protocol           = "HTTP"
      redirect           = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port               = 443
      protocol           = "HTTPS"
      ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      target_group_index = 0
      certificate_arn    = aws_acm_certificate.cert.arn

    }
  }

  name = "${var.prefix}-alb"

  security_group_description = "Security group for ALB"
  security_group_ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "TCP"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  ]
  security_group_name = "${var.prefix}-alb-sg"
  subnets             = module.vpc.public_subnets

  target_groups = {
    nextcloud_http = {
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        path                = "/status.php"
        port                = "traffic-port"
        protocol            = "HTTP"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
    nextcloud_https = {
      backend_protocol = "HTTPS"
      backend_port     = 443
      target_type      = "instance"
      health_check = {
        path                = "/status.php"
        port                = "traffic-port"
        protocol            = "HTTPS"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  }

  vpc_id = module.vpc.vpc_id
}

# module "rds_security_group" {
#   source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=20e107f1658bc5c8b23efce2e17406e74e6cbeae"

#   name        = "${var.prefix}-rds-sg"
#   description = "Security group for NextCloud RDS instance"
#   vpc_id      = module.vpc.vpc_id

#   ingress_cidr_blocks = []
#   ingress_rules       = []
#   egress_rules        = ["all-all"]
# }

# module "rds" {
#   source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git?ref=a4ae4a51545f5cb617d30b716f6bf11840c76a0e"

#   identifier = "${var.prefix}-rds"

#   allocated_storage           = 20
#   allow_major_version_upgrade = true
#   allow_minor_version_upgrade = true

#   backup_retention_period = 7
#   backup_window           = "03:00-04:00"

#   cloudwatch_log_group_class             = "INFREQUENT_ACCESS"
#   cloudwatch_log_group_retention_in_days = 14
#   create_cloudwatch_log_group            = true
#   create_db_subnet_group                 = true
#   create_monitoring_role                 = true

#   db_name                     = "nextcloud"
#   db_subnet_group_description = "DB subnet group for NextCloud RDS instance"
#   db_subnet_group_name        = "${var.prefix}-db-subnet-group"

#   enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
#   engine                          = "postgresql"
#   engine_version                  = "16.3"

#   family = "postgres16"

#   instance_class = "db.t3.medium"

#   maintenance_window          = "Mon:04:00-Mon:05:00"
#   manage_master_user_password = true
#   max_allocated_storage       = 40
#   monitoring_interval         = 60
#   monitoring_role_description = "Role for RDS monitoring"
#   monitoring_role_name        = "${var.prefix}-rds-monitoring-role"
#   multi_az                    = false

#   option_group_description = "Option group for NextCloud RDS instance"
#   option_group_name        = "${var.prefix}-rds-option-group"

#   parameter_group_description = "Parameter group for NextCloud RDS instance"
#   parameter_group_name        = "${var.prefix}-rds-parameter-group"

#   password                              = var.rds_password
#   performance_insights_enabled          = true
#   performance_insights_retention_period = 7

#   snapshot_identifier = "${var.prefix}-rds-snapshot"
#   storage_type        = "gp3"
#   subnet_ids          = module.vpc.private_subnets

#   username = var.prefix

#   vpc_security_group_ids = [module.rds_security_group.security_group_id]
# }

# TODO: Complete the following modules
# https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-that-s3-buckets-are-encrypted-with-kms-by-default
# https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/s3-policies/s3-13-enable-logging
# https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/s3-bucket-should-have-public-access-blocks-defaults-to-false-if-the-public-access-block-is-not-attached
# https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-logging-policies/bc-aws-2-62
# https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-logging-policies/bc-aws-2-61
# https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/ensure-that-s3-bucket-has-cross-region-replication-enabled


module "s3-bucket-landing" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=8a0b697adfbc673e6135c70246cff7f8052ad95a"

  bucket = "${var.prefix}-landing-bucket"


  versioning = {
    enabled = true
  }
}

module "s3-bucket-staging" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=8a0b697adfbc673e6135c70246cff7f8052ad95a"

  bucket = "${var.prefix}-staging-bucket"

  versioning = {
    enabled = true
  }
}

## Cognito user pool with resources (there's no module for this)

# module "cognito" {
#   source = "./modules/cognito"

#   cognito_user_pool_name = "${var.prefix}-cognito-user-pool"
#   cognito_user_usernames = [
#     {
#       username = "${var.prefix}-admin"
#     },
#     {
#       username = "${var.prefix}-regular-user"
#     }
#   ]
# }
