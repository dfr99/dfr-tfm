module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=2e417ad0ce830893127476436179ef483485ae84"

  azs = ["eu-central-1a", "eu-central-1b"]

  cidr                                 = "10.0.0.0/16"
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  enable_flow_log    = true
  enable_nat_gateway = true

  flow_log_cloudwatch_log_group_class             = "INFREQUENT_ACCESS"
  flow_log_cloudwatch_log_group_retention_in_days = 365
  flow_log_cloudwatch_log_group_skip_destroy      = true
  flow_log_destination_type                       = "cloud-watch-logs"
  flow_log_max_aggregation_interval               = 60
  flow_log_file_format                            = "plain-text"
  flow_log_traffic_type                           = "ALL"
  flow_log_per_hour_partition                     = true

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false
  manage_default_vpc            = false

  name = "${var.name_prefix}-vpc"

  private_subnets = [
    "${cidrsubnet(module.vpc.vpc_cidr_block, 8, 1)}",
    "${cidrsubnet(module.vpc.vpc_cidr_block, 8, 2)}"
  ]
  private_subnet_names = [
    "${var.name_prefix}-private-subnet-1",
    "${var.name_prefix}-private-subnet-2"
  ]
  private_subnet_suffix = ""

  public_subnets = [
    "${cidrsubnet(module.vpc.vpc_cidr_block, 8, 3)}",
    "${cidrsubnet(module.vpc.vpc_cidr_block, 8, 4)}"
  ]
  public_subnet_names = [
    "${var.name_prefix}-public-subnet-1",
    "${var.name_prefix}-public-subnet-2"
  ]
  public_subnet_suffix = ""

  single_nat_gateway = true

  vpc_flow_log_iam_policy_name = "${var.name_prefix}-vpc-flow-log-iam-policy"
  vpc_flow_log_iam_role_name   = "${var.name_prefix}-vpc-flow-log-iam-role"
}

###############################################################################

# TODO: Add the module for the security group

resource "aws_security_group" "ec2_security_group" {
  name        = "${var.name_prefix}-ec2-sg"
  description = "Security group for NextCloud EC2 instance"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ingress_allow_http" {
  security_group_id = aws_security_group.ec2_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ingress_allow_https" {
  security_group_id = aws_security_group.ec2_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ingress_allow_smtps" {
  security_group_id = aws_security_group.ec2_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 465
  ip_protocol = "tcp"
  to_port     = 465
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ingress_allow_8080" {
  security_group_id = aws_security_group.ec2_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ingress_allow_icpmv4" {
  security_group_id = aws_security_group.ec2_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = -1
  ip_protocol = "icmp"
  to_port     = -1
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ingress_allow_icpmv6" {
  security_group_id = aws_security_group.ec2_security_group.id

  cidr_ipv6   = "::/0"
  ip_protocol = "icmpv6"
}

resource "aws_vpc_security_group_egress_rule" "ec2_egress_allow_all_ipv4" {
  security_group_id = aws_security_group.ec2_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "ec2_egress_allow_all_ipv6" {
  security_group_id = aws_security_group.ec2_security_group.id

  cidr_ipv6   = "::/0"
  ip_protocol = -1
}

###############################################################################

resource "aws_iam_policy" "ec2_s3_access" {
  name        = "${var.name_prefix}-ec2-s3-access"
  description = "Policy for EC2 instances to interact with S3 buckets"
  policy = templatefile("${path.module}/templates/iam_policies/access_landing_bucket.tftpl", {
    landing_bucket = module.s3-bucket-landing.s3_bucket_arn
  })
}

###############################################################################

module "ec2" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git?ref=4f8387d0925510a83ee3cb88c541beb77ce4bad6"
  count  = 1

  ami = "ami-0e872aee57663ae2d" # Ubuntu Server 24.04 LTS (HVM), SSD Volume Type

  create_iam_instance_profile = true

  iam_role_description = "Role for EC2 instances"
  iam_role_name        = "${var.name_prefix}-ec2-role"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    CloudWatchAgentServerPolicy  = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    S3Landing                    = aws_iam_policy.ec2_s3_access.arn
  }
  instance_type = "t3.medium"

  metadata_options = {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  monitoring = true

  name = "${var.name_prefix}-ec2"

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

  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
}

###############################################################################

resource "aws_acm_certificate" "cert" {
  certificate_body  = file("${path.module}/certs/dfr-tfm-nextcloud.duckdns.org.crt")
  certificate_chain = file("${path.module}/certs/dfr-tfm-nextcloud.duckdns.org.chain.crt")
  private_key       = file("${path.module}/certs/dfr-tfm-nextcloud.duckdns.org.key")

  lifecycle {
    create_before_destroy = true
  }
}

###############################################################################

module "alb" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git?ref=ce3014eea6f44d5078b76ddc92f1cbe0df418cd2"

  access_logs = {
    bucket = module.s3-bucket-logs.s3_bucket_arn
    prefix = "${var.name_prefix}-alb-access-logs"
  }

  connection_logs = {
    bucket  = module.s3-bucket-logs.s3_bucket_arn
    prefix  = "${var.name_prefix}-alb-connection-logs"
    enabled = true
  }

  enable_tls_version_and_cipher_suite_headers = true

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = aws_acm_certificate.cert.arn
      forward = {
        target_group_arn = module.alb.target_groups["nextcloud"].arn
      }
    }
  }

  name = "${var.name_prefix}-alb"

  security_group_description = "Security group for ALB"
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "10.0.0.0/16"
    }
  }
  security_group_name = "${var.name_prefix}-alb-sg"
  subnets             = module.vpc.public_subnets

  target_groups = {
    nextcloud = {
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_id        = module.ec2[0].id
      target_type      = "instance"
      health_check = {
        path                = "/status.php"
        port                = "8080"
        protocol            = "HTTP"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  }

  vpc_id = module.vpc.vpc_id
}

###############################################################################

resource "aws_security_group" "rds_security_group" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Security group for NextCloud RDS instance"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress_allow_psql_from_vpc" {
  security_group_id = aws_security_group.rds_security_group.id

  cidr_ipv4   = module.vpc.vpc_cidr_block
  from_port   = 5432
  ip_protocol = "tcp"
  to_port     = 5432
}

resource "aws_vpc_security_group_egress_rule" "rds_egress_allow_all" {
  security_group_id = aws_security_group.rds_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.rds_security_group.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

###############################################################################

module "rds" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds.git?ref=a4ae4a51545f5cb617d30b716f6bf11840c76a0e"

  identifier = "${var.name_prefix}-rds"

  allocated_storage           = 20
  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true

  backup_retention_period = 7
  backup_window           = "03:00-04:00"

  cloudwatch_log_group_class             = "INFREQUENT_ACCESS"
  cloudwatch_log_group_retention_in_days = 365
  create_cloudwatch_log_group            = true
  create_db_subnet_group                 = true
  create_monitoring_role                 = true

  db_name                     = "nextcloud"
  db_subnet_group_description = "DB subnet group for NextCloud RDS instance"
  db_subnet_group_name        = "${var.name_prefix}-db-subnet-group"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  engine                          = "postgres"
  engine_version                  = "16.3"

  family = "postgres16"

  instance_class = "db.t3.medium"

  maintenance_window                                     = "Mon:04:00-Mon:05:00"
  major_engine_version                                   = "16"
  manage_master_user_password                            = true
  manage_master_user_password_rotation                   = true
  master_user_password_rotation_automatically_after_days = 90
  max_allocated_storage                                  = 40
  monitoring_interval                                    = 60
  monitoring_role_description                            = "Role for RDS monitoring"
  monitoring_role_name                                   = "${var.name_prefix}-rds-monitoring-role"
  multi_az                                               = false

  option_group_description = "Option group for NextCloud RDS instance"
  option_group_name        = "${var.name_prefix}-rds-option-group"

  parameter_group_description = "Parameter group for NextCloud RDS instance"
  parameter_group_name        = "${var.name_prefix}-rds-parameter-group"

  password                              = var.rds_password
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  storage_type = "gp3"
  subnet_ids   = module.vpc.private_subnets

  username = var.name_prefix

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
}

###############################################################################

module "s3-bucket-logs" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=8a0b697adfbc673e6135c70246cff7f8052ad95a"

  bucket              = "${var.name_prefix}-logging-bucket"
  block_public_acls   = true
  block_public_policy = true

  lifecycle_rule = [
    {
      id     = "expire"
      status = "Enabled"
      prefix = "logs/"
      transition = [{
        days          = 30
        storage_class = "STANDARD_IA"
      }]
      expiration = {
        days = 90
      }
      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }
    }
  ]

  versioning = {
    enabled = true
    status  = "Enabled"
  }
}

###############################################################################

module "s3-bucket-landing" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=8a0b697adfbc673e6135c70246cff7f8052ad95a"

  bucket              = "${var.name_prefix}-landing-bucket"
  block_public_acls   = true
  block_public_policy = true

  lifecycle_rule = [
    {
      id     = "expire"
      status = "Enabled"
      prefix = "logs/"
      transition = [{
        days          = 30
        storage_class = "STANDARD_IA"
      }]
      expiration = {
        days = 90
      }
      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }
    }
  ]

  versioning = {
    enabled = true
    status  = "Enabled"
  }
}

###############################################################################

module "s3-bucket-staging" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=8a0b697adfbc673e6135c70246cff7f8052ad95a"

  bucket              = "${var.name_prefix}-staging-bucket"
  block_public_acls   = true
  block_public_policy = true

  lifecycle_rule = [
    {
      id     = "expire"
      status = "Enabled"
      prefix = "logs/"
      transition = [{
        days          = 30
        storage_class = "STANDARD_IA"
      }]
      expiration = {
        days = 90
      }
      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }
    }
  ]

  logging = {
    target_bucket = "${var.name_prefix}-logging-bucket"
    target_prefix = "${var.name_prefix}-staging-bucket/"
  }

  versioning = {
    enabled = true
    status  = "Enabled"
  }
}

###############################################################################

## Cognito user pool with resources (there's no module for this)

# module "cognito" {
#   source = "./modules/cognito"

#   cognito_user_pool_name = "${var.name_prefix}-cognito-user-pool"
#   cognito_user_usernames = [
#     {
#       username = "${var.name_prefix}-admin"
#     },
#     {
#       username = "${var.name_prefix}-regular-user"
#     }
#   ]
# }

resource "aws_resourcegroups_group" "github_runner" {
  name        = "${var.name_prefix}-rg"
  description = "Resource Group for OIDC GitHub Actions Identity Provider"

  resource_query {
    type = "TAG_FILTERS_1_0"
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"],
      TagFilters = [{
        Key    = "Project",
        Values = ["nextcloud"]
      }]
    })
  }

  tags = {
    "Name" = "${var.name_prefix}-rg"
  }
}
