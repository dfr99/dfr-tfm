# github-runner

<!-- BEGIN_TF_DOCS -->
# Github Runner Terraform configuration

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.8.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.56.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.56.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git | 4f8387d0925510a83ee3cb88c541beb77ce4bad6 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.github-runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.github-runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_resourcegroups_group.github_runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/resourcegroups_group) | resource |
| [aws_security_group.github_runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4_on_github_runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv6_on_github_runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow_https_ipv4_on_github_runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow_https_ipv6_on_github_runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gh_pat"></a> [gh\_pat](#input\_gh\_pat) | GitHub Personal Access Token to configure GitHub Runner | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for the name of the resources | `string` | `"github-runner"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
