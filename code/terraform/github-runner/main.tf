### IAM Instance Profile
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "github-runner" {
  name               = "${var.name_prefix}-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    "Name" = "${var.name_prefix}-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.github-runner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.github-runner.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "github-runner" {
  name = "github-runner"
  role = aws_iam_role.github-runner.name
}

### EC2 instance security group
resource "aws_security_group" "github_runner" {
  name        = "${var.name_prefix}-sg"
  description = "Allow HTTPS inbound traffic and all outbound traffic"
  vpc_id      = "vpc-d90be2b0"

  tags = {
    "Name" = "${var.name_prefix}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4_on_github_runner" {
  security_group_id = aws_security_group.github_runner.id
  cidr_ipv4         = "0.0.0.0/16"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "Allow IPv4 HTTPS inbound traffic from anywhere"
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv6_on_github_runner" {
  security_group_id = aws_security_group.github_runner.id
  cidr_ipv6         = "::/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "Allow IPv6 HTTPS inbound traffic from anywhere"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_on_github_runner" {
  security_group_id = aws_security_group.github_runner.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all IPv4 outbound traffic"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6_on_github_runner" {
  security_group_id = aws_security_group.github_runner.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
  description       = "Allow all IPv6 outbound traffic"
}

### EC2 instance
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "ec2" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git?ref=4f8387d0925510a83ee3cb88c541beb77ce4bad6"

  name          = "github-runner"
  ami           = "ami-0e872aee57663ae2d"
  instance_type = "t3.micro"

  create               = true
  iam_instance_profile = aws_iam_instance_profile.github-runner.id

  create_spot_instance                = true
  spot_price                          = "0.006"
  spot_type                           = "persistent"
  spot_instance_interruption_behavior = "stop"

  metadata_options = {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring = true

  subnet_id              = "subnet-e38ca1a9"
  vpc_security_group_ids = [aws_security_group.github_runner.id]

  user_data = templatefile("templates/user_data.tftpl", {
    gh_pat      = var.gh_pat
    aws_account = data.aws_caller_identity.current.account_id
    aws_region  = data.aws_region.current.name
  })
  user_data_replace_on_change = true

  tags = {
    "Name" = "${var.name_prefix}-ec2"
  }
}

resource "aws_resourcegroups_group" "github_runner" {
  name        = "${var.name_prefix}-rg"
  description = "Resource Group for GitHub Runner resources"

  resource_query {
    type = "TAG_FILTERS_1_0"
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"],
      TagFilters = [{
        Key    = "Project",
        Values = ["${var.name_prefix}"]
      }]
    })
  }

  tags = {
    "Name" = "${var.name_prefix}-rg"
  }
}
