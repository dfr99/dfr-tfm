/**
 * # OIDC GitHub Actions: IAM Role Terraform configuration
 */

terraform {
  required_version = "1.8.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.56.1"
    }
  }

  backend "s3" {
    bucket               = "torusware-terraform-states"
    key                  = "terraform.tfstate"
    dynamodb_table       = "torusware-terraform-states-lock-id"
    region               = "eu-west-1"
    workspace_key_prefix = "dfr-tfm/oidc-github-actions/iam_role"
  }
}

provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      "OIDC"      = "GitHub"
      "Terraform" = "True"
      "Project"   = "oidc-github-actions/iam_role"
      "Owner"     = "dfr99"
      "Repo"      = "dfr-tfm"
    }
  }
}
