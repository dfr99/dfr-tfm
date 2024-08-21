<!-- BEGIN_TF_DOCS -->
# Cognito User Terraform configuration

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
| [aws_cognito_user.user](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/cognito_user) | resource |
| [aws_cognito_user_in_group.user_in_group](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/cognito_user_in_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cognito_user_group"></a> [cognito\_user\_group](#input\_cognito\_user\_group) | The name of the group to which the user is to be added. | `string` | n/a | yes |
| <a name="input_cognito_user_pool_id"></a> [cognito\_user\_pool\_id](#input\_cognito\_user\_pool\_id) | The user pool ID for the user pool where the user will be created. | `string` | n/a | yes |
| <a name="input_cognito_username"></a> [cognito\_username](#input\_cognito\_username) | The username for the user. Must be unique within the user pool. Must be a UTF-8 string between 1 and 128 characters. After the user is created, the username cannot be changed. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
