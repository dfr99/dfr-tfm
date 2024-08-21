resource "aws_cognito_user" "user" {
  user_pool_id = var.cognito_user_pool_id
  username     = var.cognito_username
}

resource "aws_cognito_user_in_group" "user_in_group" {
  user_pool_id = var.cognito_user_pool_id
  group_name   = var.cognito_user_group
  username     = aws_cognito_user.user.username
}
