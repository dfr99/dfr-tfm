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

resource "aws_resourcegroups_group" "github_runner" {
  name        = "iam-role-${terraform.workspace}-rg"
  description = "Resource Group for OIDC GitHub Actions Identity Provider"

  resource_query {
    type = "TAG_FILTERS_1_0"
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"],
      TagFilters = [{
        Key    = "Project",
        Values = ["oidc-github-actions/iam_role"]
      }]
    })
  }

  tags = {
    "Name" = "iam-role-${terraform.workspace}-rg"
  }
}
