resource "aws_iam_role" "oidc_github_role" {
  name        = "oidc-github-actions-dfr-tfm-role-${terraform.workspace}"
  path        = "/"
  description = "Role to access AWS from GitHub Actions on dfr99/dfr-tfm repository with ${terraform.workspace} permissions"

  assume_role_policy = templatefile("./templates/oidc-github-actions-trust-relationship.tftpl",
    {
      oidc_github_arn = var.oidc_github_arn
      repository      = var.repository
    }
  )
}

resource "aws_iam_role_policy_attachment" "permisions" {
  role       = aws_iam_role.oidc_github_role.name
  policy_arn = var.permisions[terraform.workspace]
}
