resource "aws_codeartifact_domain" "kahula" {
  domain = "kahula"

  tags = {
    Terraform = "true"
  }
}

resource "aws_codeartifact_repository" "data_models" {
  repository = "data-models"
  domain     = aws_codeartifact_domain.kahula.domain

  tags = {
    Terraform = "true"
  }
}
