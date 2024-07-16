output "oidc_github_role_arn" {
  value     = aws_iam_role.oidc_github_role.arn
  sensitive = true
}
