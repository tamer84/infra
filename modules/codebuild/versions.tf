terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.31"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.5.1"
    }
  }
}