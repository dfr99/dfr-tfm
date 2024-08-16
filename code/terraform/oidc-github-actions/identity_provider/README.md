# oidc_github_actions/identity_provider

<!-- BEGIN_TF_DOCS -->
# OIDC Github Actions: Identity Provider Terraform configuration

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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.oidc_github](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/iam_openid_connect_provider) | resource |
| [aws_resourcegroups_group.github_runner](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/resourcegroups_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oidc_github_arn"></a> [oidc\_github\_arn](#output\_oidc\_github\_arn) | n/a |
<!-- END_TF_DOCS -->
