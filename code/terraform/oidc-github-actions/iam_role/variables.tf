variable "oidc_github_arn" {
  type        = string
  description = "The ARN assigned by AWS for this OIDC GitHub provider"
  sensitive   = true

  validation {
    condition     = can(regex("^arn:aws:iam::", var.oidc_github_arn))
    error_message = "The OIDC GitHub ARN must be valid. Syntax is \"arn:aws:iam::<aws_account_id>:oidc-provider/token.actions.githubusercontent.com\"."
  }
}

variable "repository" {
  type        = string
  description = "The GitHub repository name"
  sensitive   = false

  validation {
    condition     = can(regex("^[0-9a-zA-Z\\/\\-\\_]", var.repository))
    error_message = "The repository must be valid. Syntax is \"<owner>/<repository_name>\"."
  }
}

variable "permisions" {
  type        = map(string)
  description = "ARN of the default policies to attach to the role"
  sensitive   = false

  default = {
    "readonly" = "arn:aws:iam::aws:policy/ReadOnlyAccess"
    "admin"    = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
}
