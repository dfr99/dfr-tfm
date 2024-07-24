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
  name               = "github-runner"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
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
  name        = "github-runner-sg"
  description = "Allow HTTPS inbound traffic and all outbound traffic"
  vpc_id      = "vpc-d90be2b0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4_on_github_runner" {
  security_group_id = aws_security_group.github_runner.id
  cidr_ipv4         = "0.0.0.0/16"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv6_on_github_runner" {
  security_group_id = aws_security_group.github_runner.id
  cidr_ipv6         = "::/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_on_github_runner" {
  security_group_id = aws_security_group.github_runner.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6_on_github_runner" {
  security_group_id = aws_security_group.github_runner.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

### EC2 instance
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name          = "github-runner"
  ami           = "ami-0e872aee57663ae2d"
  instance_type = "t3.micro"

  create               = true
  iam_instance_profile = aws_iam_instance_profile.github-runner.id

  create_spot_instance                = true
  spot_price                          = "0.006"
  spot_type                           = "persistent"
  spot_instance_interruption_behavior = "stop"

  monitoring = true

  subnet_id              = "subnet-e38ca1a9"
  vpc_security_group_ids = [aws_security_group.github_runner.id]

  user_data = templatefile("templates/user_data.tftpl", {
    gh_pat      = var.gh_pat
    aws_account = data.aws_caller_identity.current.account_id
    aws_region  = data.aws_region.current.name
  })
  user_data_replace_on_change = true
}
