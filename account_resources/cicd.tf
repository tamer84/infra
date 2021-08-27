####
# Diogo hard coded this to the DEV VPCs in VPP, as that kicked off the CI/CD.
# And for MAIN releases it was hardcoded directly to the PROD VPCID / SubnetIDs
# means if we want to reuse this we should disable the entire module till we run the Env resources once to setup our new DEV.
# Then we need to update this script with the new environments vpc_id / subnet_ids

# ========================================
# CICD
# ========================================
locals {
  mbocdp_infra_branch_develop = "develop"
  mbocdp_infra_branch_main    = "main"
}

module "cicd_develop" {
  source = "../modules/cicd"

  codestar_connection_arn = aws_codestarconnections_connection.daimler_git_conn.arn

  pipeline_base_configs = {
    "name"        = "infra-account-resources-dev"
    "bucket_name" = aws_s3_bucket.cicd_bucket.id
    "role_arn"    = aws_iam_role.cicd_role.arn
  }

  codebuild_build_stage = {
    "project_name"        = "infra-account-resources-dev"
    "github_branch"       = local.mbocdp_infra_branch_develop
    "github_organisation" = "mboc-dp"
    "github_repo"         = "infra"
    "github_access_token" = data.external.github_access_token.result["token"]
    "github_certificate"  = "${aws_s3_bucket.cicd_bucket.arn}/${aws_s3_bucket_object.github_cert.id}"

    "service_role_arn"   = aws_iam_role.cicd_role.arn
    "cicd_bucket_id"     = aws_s3_bucket.cicd_bucket.id
    "vpc_id"             = "vpc-0ce6264eb20f5e516"
    "subnets_ids"        = ["subnet-025fb16356052b4f9", "subnet-0bea4580d3c50369a"]
    "security_group_ids" = ["sg-0c83ccf0ba0e28fd5"]

    "docker_img_url"                   = "736578946942.dkr.ecr.eu-central-1.amazonaws.com/terraform-build-image-dev"
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
        value = "account_resources"
      },
      {
        name  = "CONTEXT",
        value = "account-resources"
      }
    ]
  }
}

module "cicd_main" {
  source = "../modules/cicd"

  codestar_connection_arn = aws_codestarconnections_connection.daimler_git_conn.arn

  pipeline_base_configs = {
    "name"        = "infra-account-resources-prod"
    "bucket_name" = aws_s3_bucket.cicd_bucket.id
    "role_arn"    = aws_iam_role.cicd_role.arn
  }

  codebuild_build_stage = {
    "project_name"        = "infra-account-resources-prod"
    "github_branch"       = local.mbocdp_infra_branch_main
    "github_organisation" = "mboc-dp"
    "github_repo"         = "infra"
    "github_access_token" = data.external.github_access_token.result["token"]
    "github_certificate"  = "${aws_s3_bucket.cicd_bucket.arn}/${aws_s3_bucket_object.github_cert.id}"

    "service_role_arn"   = aws_iam_role.cicd_role.arn
    "cicd_bucket_id"     = aws_s3_bucket.cicd_bucket.id
    "vpc_id"             = "vpc-04f64e7b7ede45d19"
    "subnets_ids"        = ["subnet-09162ac076cc6b109", "subnet-0fe64ded12da9f01d"]
    "security_group_ids" = ["sg-08dfbd687dbaddcb2"]

    "docker_img_url"                   = "736578946942.dkr.ecr.eu-central-1.amazonaws.com/terraform-build-image-prod"
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
        value = "account_resources"
      },
      {
        name  = "CONTEXT",
        value = "account-resources"
      }
    ]
  }
}
