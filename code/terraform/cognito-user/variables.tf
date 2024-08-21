variable "cognito_user_pool_id" {
  type        = string
  description = "The user pool ID for the user pool where the user will be created."
  sensitive   = true
}

variable "cognito_username" {
  type        = string
  description = "The username for the user. Must be unique within the user pool. Must be a UTF-8 string between 1 and 128 characters. After the user is created, the username cannot be changed."
  sensitive   = false
}

variable "cognito_user_group" {
  type        = string
  description = "The name of the group to which the user is to be added."
  sensitive   = false
}
