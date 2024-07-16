output "oidc_github_arn" {
  value     = aws_iam_openid_connect_provider.oidc_github.arn
  sensitive = true
}
