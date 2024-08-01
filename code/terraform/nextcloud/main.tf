module "vpc" {
  source  = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=2e417ad0ce830893127476436179ef483485ae84"

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

# module "ec2" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "5.6.1"
# }

# module "rds" {
#   source  = "terraform-aws-modules/rds/aws"
#   version = "6.8.0"

#   identifier = "${var.prefix}-rds"
# }

# module "s3-bucket-landing" {
#   source  = "terraform-aws-modules/s3-bucket/aws"
#   version = "4.1.2"
# }

# module "s3-bucket-staging" {
#   source  = "terraform-aws-modules/s3-bucket/aws"
#   version = "4.1.2"
# }

## Cognito user pool with resources (there's no module for this)

