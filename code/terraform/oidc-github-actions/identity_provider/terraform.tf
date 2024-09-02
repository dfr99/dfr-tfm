/**
 * # OIDC Github Actions: Identity Provider Terraform configuration
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
    bucket         = "torusware-terraform-states"
    key            = "dfr-tfm/oidc-github-actions/identity_provider/terraform.tfstate"
    dynamodb_table = "torusware-terraform-states-lock-id"
    region         = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      "user:OIDC"      = "GitHub"
      "user:Terraform" = "True"
      "user:Project"   = "oidc-github-actions/identity_provider"
      "user:Owner"     = "dfr99"
      "user:Repo"      = "dfr-tfm"
    }
  }
}
