data "external" "github_access_token" {
  program = ["bash", "get_secret.sh", "github-access-token"]
}

data "external" "certificate_com" {
  program = ["bash", "get_secret_cert.sh", "certificate_com"]
}
