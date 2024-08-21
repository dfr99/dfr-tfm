<!-- BEGIN_TF_DOCS -->
# Cognito Group Terraform configuration

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
| [aws_cognito_user_group.cognito_group](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/cognito_user_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cognito_user_pool_id"></a> [cognito\_user\_pool\_id](#input\_cognito\_user\_pool\_id) | The user pool ID. | `string` | n/a | yes |
| <a name="input_group_name"></a> [group\_name](#input\_group\_name) | The name of the user group. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
