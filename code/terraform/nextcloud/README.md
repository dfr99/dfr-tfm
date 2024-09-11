<!-- BEGIN_TF_DOCS -->
# NextCloud Terraform configuration

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.8.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.59.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.59.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | git::https://github.com/terraform-aws-modules/terraform-aws-alb.git | ce3014eea6f44d5078b76ddc92f1cbe0df418cd2 |
| <a name="module_ec2"></a> [ec2](#module\_ec2) | git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git | 4f8387d0925510a83ee3cb88c541beb77ce4bad6 |
| <a name="module_lambda-sns-topic"></a> [lambda-sns-topic](#module\_lambda-sns-topic) | git::https://github.com/terraform-aws-modules/terraform-aws-sns | 6404f81a23544d2aba6c9c178cdf97290cee0e90 |
| <a name="module_rds"></a> [rds](#module\_rds) | git::https://github.com/terraform-aws-modules/terraform-aws-rds.git | a4ae4a51545f5cb617d30b716f6bf11840c76a0e |
| <a name="module_s3-bucket-landing"></a> [s3-bucket-landing](#module\_s3-bucket-landing) | git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git | 8a0b697adfbc673e6135c70246cff7f8052ad95a |
| <a name="module_s3-bucket-logs"></a> [s3-bucket-logs](#module\_s3-bucket-logs) | git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git | 8a0b697adfbc673e6135c70246cff7f8052ad95a |
| <a name="module_s3-bucket-staging"></a> [s3-bucket-staging](#module\_s3-bucket-staging) | git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git | 8a0b697adfbc673e6135c70246cff7f8052ad95a |
| <a name="module_s3-landing-notification-sqs"></a> [s3-landing-notification-sqs](#module\_s3-landing-notification-sqs) | git::https://github.com/terraform-aws-modules/terraform-aws-sqs.git | 8c18f70fd765db2adf31edf5fc15b3058367e5a2 |
| <a name="module_s3-sns-topic"></a> [s3-sns-topic](#module\_s3-sns-topic) | git::https://github.com/terraform-aws-modules/terraform-aws-sns | 6404f81a23544d2aba6c9c178cdf97290cee0e90 |
| <a name="module_sfm-sns-topic"></a> [sfm-sns-topic](#module\_sfm-sns-topic) | git::https://github.com/terraform-aws-modules/terraform-aws-sns | 6404f81a23544d2aba6c9c178cdf97290cee0e90 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git | 2e417ad0ce830893127476436179ef483485ae84 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/acm_certificate) | resource |
| [aws_iam_policy.ec2_s3_access](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/iam_policy) | resource |
| [aws_resourcegroups_group.github_runner](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/resourcegroups_group) | resource |
| [aws_security_group.ec2_security_group](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/security_group) | resource |
| [aws_security_group.rds_security_group](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv6](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.ec2_egress_allow_all_ipv4](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.ec2_egress_allow_all_ipv6](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.rds_egress_allow_all](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ec2_ingress_allow_8080](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ec2_ingress_allow_http](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ec2_ingress_allow_https](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ec2_ingress_allow_smtps](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.rds_ingress_allow_psql_from_vpc](https://registry.terraform.io/providers/hashicorp/aws/5.59.0/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_account_id"></a> [alb\_account\_id](#input\_alb\_account\_id) | AWS account ID for the ALB | `string` | `"054676820928"` | no |
| <a name="input_lambda_sns_topic_email"></a> [lambda\_sns\_topic\_email](#input\_lambda\_sns\_topic\_email) | SNS topic ARN for email notifications related to Lambda | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | value to be prefixed to all resources | `string` | `"nextcloud"` | no |
| <a name="input_rds_password"></a> [rds\_password](#input\_rds\_password) | password for the RDS instance | `string` | n/a | yes |
| <a name="input_s3_sns_topic_email"></a> [s3\_sns\_topic\_email](#input\_s3\_sns\_topic\_email) | SNS topic ARN for email notifications related to S3 | `string` | n/a | yes |
| <a name="input_sfm_sns_topic_email"></a> [sfm\_sns\_topic\_email](#input\_sfm\_sns\_topic\_email) | SNS topic ARN for SMS notifications related to Step Functions | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->