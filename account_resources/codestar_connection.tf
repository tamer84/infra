resource "aws_codestarconnections_host" "git_host" {
  name              = "GitHub"
  provider_endpoint = "https://github.com"
  provider_type     = "GitHub"
}

resource "aws_codestarconnections_connection" "git_conn" {
  name          = "GitHub"
  provider_type = "GitHub"
}
