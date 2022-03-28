terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.1.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.5.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
  required_version = "= 1.0.5"
}
