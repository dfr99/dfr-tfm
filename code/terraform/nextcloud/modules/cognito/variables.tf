variable "cognito_user_pool_name" {
  type        = string
  description = "The name of the Cognito User Pool"
  sensitive   = false
}

variable "cognito_mfa_configuration" {
  type        = string
  description = "The MFA configuration for the Cognito User Pool"
  sensitive   = false
}

variable "cognito_sms_authentication_message" {
  type        = string
  description = "The SMS authentication message for the Cognito User Pool"
  sensitive   = false
}

variable "cognito_user_usernames" {
  type        = list(map(string))
  description = "The usernames for the Cognito User Pool"
  sensitive   = false
}
