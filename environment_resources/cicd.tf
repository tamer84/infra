# ========================================
# CICD
# ========================================
locals {
  infra_branch = contains(["dev", "test", "int"], terraform.workspace) ? "develop" : "main"
}

module "cicd" {
  source = "../modules/cicd"

  codestar_connection_arn = data.terraform_remote_state.account_resources.outputs.dag_git_codestar_conn.arn

  pipeline_base_configs = {
    "name"        = "infra-${terraform.workspace}"
    "bucket_name" = aws_s3_bucket.cicd_bucket.id
    "role_arn"    = data.terraform_remote_state.account_resources.outputs.cicd_role.arn
  }

  codebuild_build_stage = {
    "project_name"        = "infra-${terraform.workspace}"
    "github_branch"       = local.infra_branch
    "github_organisation" = "mbocdp"
    "github_repo"         = "infra"
    "github_access_token" = data.terraform_remote_state.account_resources.outputs.github_access_token
    "github_certificate"  = "${aws_s3_bucket.cicd_bucket.arn}/${aws_s3_bucket_object.github_cert.id}"

    "service_role_arn"   = data.terraform_remote_state.account_resources.outputs.cicd_role.arn
    "cicd_bucket_id"     = aws_s3_bucket.cicd_bucket.id
    "vpc_id"             = aws_vpc.mbocdp.id
    "subnets_ids"        = aws_subnet.private-subnet.*.id
    "security_group_ids" = [aws_security_group.internal_access.id]

    ## Change this as soon as we have our own account id
    "docker_img_url"                   = "736578946942.dkr.ecr.eu-central-1.amazonaws.com/terraform-build-image-${terraform.workspace}"
    "docker_img_tag"                   = "latest"
    "docker_img_pull_credentials_type" = "SERVICE_ROLE"
    "buildspec"                        = "../buildspec.yml"
    "env_vars" = [
      {
        name  = "ENVIRONMENT"
        value = terraform.workspace
      },
      {
        name  = "BUILD_DIR",
        value = "environment_resources"
      },
      {
        name  = "CONTEXT",
        value = "env-resources"
      }
    ]
  }
}
