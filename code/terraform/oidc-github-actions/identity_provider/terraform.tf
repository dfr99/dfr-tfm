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
      "OIDC"      = "GitHub"
      "Terraform" = "True"
      "Project"   = "oidc-github-actions/identity_provider"
      "Owner"     = "dfr99"
      "Repo"      = "dfr-tfm"
    }
  }
}
