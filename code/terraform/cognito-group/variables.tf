variable "group_name" {
  type        = string
  description = "The name of the user group."
  sensitive   = false
}

variable "cognito_user_pool_id" {
  type        = string
  description = "The user pool ID."
  sensitive   = true
}
