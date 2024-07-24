<!-- BEGIN_TF_DOCS -->
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
| <a name="module_ec2"></a> [ec2](#module\_ec2) | terraform-aws-modules/ec2-instance/aws | 5.6.1 |
## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.github-runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.github-runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_agent](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.github_runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4_on_github_runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv6_on_github_runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow_https_ipv4_on_github_runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow_https_ipv6_on_github_runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/data-sources/region) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gh_pat"></a> [gh\_pat](#input\_gh\_pat) | GitHub Personal Access Token to configure GitHub Runner | `string` | n/a | yes |
## Outputs

No outputs.
<!-- END_TF_DOCS -->