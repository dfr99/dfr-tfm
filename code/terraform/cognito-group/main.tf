resource "aws_cognito_user_group" "cognito_group" {
  name         = var.group_name
  user_pool_id = var.cognito_user_pool_id
  description  = "Cognito group"
}
