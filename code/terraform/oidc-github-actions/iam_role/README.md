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
| [aws_iam_role.oidc_github_role](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.permisions](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/iam_role_policy_attachment) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_oidc_github_arn"></a> [oidc\_github\_arn](#input\_oidc\_github\_arn) | The ARN assigned by AWS for this OIDC GitHub provider | `string` | n/a | yes |
| <a name="input_permisions"></a> [permisions](#input\_permisions) | ARN of the default policies to attach to the role | `map(string)` | <pre>{<br>  "admin": "arn:aws:iam::aws:policy/AdministratorAccess",<br>  "readonly": "arn:aws:iam::aws:policy/ReadOnlyAccess"<br>}</pre> | no |
| <a name="input_repository"></a> [repository](#input\_repository) | The GitHub repository name | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oidc_github_role_arn"></a> [oidc\_github\_role\_arn](#output\_oidc\_github\_role\_arn) | Value of the OIDC GitHub Actions role ARN |

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

No modules.
## Resources

| Name | Type |
|------|------|
| [aws_iam_role.oidc_github_role](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.permisions](https://registry.terraform.io/providers/hashicorp/aws/5.56.1/docs/resources/iam_role_policy_attachment) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_oidc_github_arn"></a> [oidc\_github\_arn](#input\_oidc\_github\_arn) | The ARN assigned by AWS for this OIDC GitHub provider | `string` | n/a | yes |
| <a name="input_permisions"></a> [permisions](#input\_permisions) | ARN of the default policies to attach to the role | `map(string)` | <pre>{<br>  "admin": "arn:aws:iam::aws:policy/AdministratorAccess",<br>  "readonly": "arn:aws:iam::aws:policy/ReadOnlyAccess"<br>}</pre> | no |
| <a name="input_repository"></a> [repository](#input\_repository) | The GitHub repository name | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oidc_github_role_arn"></a> [oidc\_github\_role\_arn](#output\_oidc\_github\_role\_arn) | n/a |
<!-- END_TF_DOCS -->