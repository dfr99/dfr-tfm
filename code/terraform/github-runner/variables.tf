variable "gh_pat" {
  type        = string
  description = "GitHub Personal Access Token to configure GitHub Runner"
  sensitive   = true

  validation {
    condition     = can(regex("^ghp_", var.gh_pat))
    error_message = "The GH PAT must be valid. Syntax is \"ghp_<token_body>\"."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix for the name of the resources"
  default = "github-runner"
}
