
resource "aws_codestarconnections_connection" "git_conn" {
  name          = "GitHub"
  provider_type = "GitHub"
}
