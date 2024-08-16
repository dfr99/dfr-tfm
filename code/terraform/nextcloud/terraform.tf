/**
 * # NextCloud Terraform configuration
 */

terraform {
  required_version = "1.8.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.59.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }

  backend "s3" {
    bucket         = "torusware-terraform-states"
    key            = "dfr-tfm/nextcloud/terraform.tfstate"
    dynamodb_table = "torusware-terraform-states-lock-id"
    region         = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      "Terraform" = "True"
      "Project"   = "nextcloud"
      "Owner"     = "dfr99"
      "Repo"      = "dfr-tfm"
    }
  }
}

provider "random" {}


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}
