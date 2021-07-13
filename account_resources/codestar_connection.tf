resource "aws_codestarconnections_host" "daimler_git_host" {
  name              = "Daimler GitHub"
  provider_endpoint = "https://git.daimler.com/"
  provider_type     = "GitHubEnterpriseServer"
}

resource "aws_codestarconnections_connection" "daimler_git_conn" {
  name          = "Daimler GitHub"
  provider_type = "GitHubEnterpriseServer"
}
