terraform {
  backend "s3" {
    encrypt        = "true"
    bucket         = "mbocdp-terraform"
    key            = "account_resources/tfstate.tf"
    region         = "eu-central-1"
    dynamodb_table = "terraform"
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  region = "us-east-1"
  alias  = "use1"
}

provider "archive" {}

provider "null" {}

provider "github" {
  token        = data.external.github_access_token.result["token"]
  organization = "mboc-dp"
  base_url     = "https://git.daimler.com/"
}

data "aws_caller_identity" "current" {}
