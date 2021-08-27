data "external" "github_access_token" {
  program = ["bash", "get_secret.sh", "github-access-token"]
}

