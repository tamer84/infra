terraform {
  backend "s3" {
    encrypt        = "true"
    bucket         = "kahula-terraform"
    key            = "environment_resources/tfstate.tf"
    region         = "eu-central-1"
    dynamodb_table = "terraform"
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "github" {
  token        = data.terraform_remote_state.account_resources.outputs.github_access_token
  organization = "mboc-dp"
  base_url     = "https://git.daimler.com/"
}

data "terraform_remote_state" "account_resources" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "kahula-terraform"
    key     = "account_resources/tfstate.tf"
    region  = "eu-central-1"
  }
  workspace = "default"
}

data "aws_caller_identity" "current" {}
