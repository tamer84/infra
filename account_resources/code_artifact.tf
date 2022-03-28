resource "aws_codeartifact_domain" "tango" {
  domain = "tango"

  tags = {
    Terraform = "true"
  }
}

resource "aws_codeartifact_repository" "data_models" {
  repository = "data-models"
  domain     = aws_codeartifact_domain.tango.domain

  tags = {
    Terraform = "true"
  }
}
