resource "aws_iam_openid_connect_provider" "oidc_github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
}

resource "aws_resourcegroups_group" "github_runner" {
  name        = "identity-provider-rg"
  description = "Resource Group for OIDC GitHub Actions Identity Provider"

  resource_query {
    type = "TAG_FILTERS_1_0"
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"],
      TagFilters = [{
        Key    = "Project",
        Values = ["oidc-github-actions/identity_provider"]
      }]
    })
  }

  tags = {
    "Name" = "identity-provider-rg"
  }
}