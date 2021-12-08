locals {
  source_stage = {
    "name"                    = "Source",
    "codestar_connection_arn" = var.codestar_connection_arn,
    "full_repo_id"            = "/${var.codebuild_build_stage["github_repo"]}",
    "branch_name"             = var.codebuild_build_stage["github_branch"]
  }

  tests_source_stage = var.codebuild_run_tests_stage != null ? {
    "name"                    = "TestsSource",
    "codestar_connection_arn" = var.codestar_connection_arn,
    "full_repo_id"            = "/${var.codebuild_run_tests_stage["github_repo"]}",
    "branch_name"             = var.codebuild_run_tests_stage["github_branch"]
  } : null

  build_stage = {
    "name"         = var.deploy_stage_ecs == null ? "BuildAndDeploy" : "Build",
    "project_name" = var.codebuild_build_stage["project_name"]
  }

  run_tests_stage = var.codebuild_run_tests_stage != null ? {
    "name"         = "RunTests",
    "project_name" = var.codebuild_run_tests_stage["project_name"]
  } : null
}

# ======================================================= #
# CodeBuild job to build (and deploy Lambda applications) #
# ======================================================= #
module "build_job" {
  source = "git::ssh://git@github.com/tamer84/infra.git//modules/codebuild?ref=develop"

  project_name     = var.codebuild_build_stage["project_name"]
  service_role_arn = var.codebuild_build_stage["service_role_arn"]

  cicd_branch         = var.codebuild_build_stage["github_branch"]
  github_repository   = var.codebuild_build_stage["github_repo"]
  github_access_token = var.codebuild_build_stage["github_access_token"]
  github_certificate  = var.codebuild_build_stage["github_certificate"]
  insecure_ssl        = false

  cicd_bucket_id              = var.codebuild_build_stage["cicd_bucket_id"]
  build_image_url             = var.codebuild_build_stage["docker_img_url"]
  build_image_tag             = var.codebuild_build_stage["docker_img_tag"]
  image_pull_credentials_type = var.codebuild_build_stage["docker_img_pull_credentials_type"]

  vpc_id             = var.codebuild_build_stage["vpc_id"]
  subnets_ids        = var.codebuild_build_stage["subnets_ids"]
  security_group_ids = var.codebuild_build_stage["security_group_ids"]

  buildspec_file        = file(var.codebuild_build_stage["buildspec"])
  environment_variables = var.codebuild_build_stage["env_vars"]
}

# ============================== #
# CodeBuild job to run the tests #
# ============================== #
module "run_tests_job" {
  source = "git::ssh://git@github.com/tamer84/infra.git//modules/codebuild?ref=develop"
  count  = var.codebuild_run_tests_stage != null ? 1 : 0

  project_name     = var.codebuild_run_tests_stage["project_name"]
  service_role_arn = var.codebuild_run_tests_stage["service_role_arn"]

  cicd_branch         = var.codebuild_run_tests_stage["github_branch"]
  github_repository   = var.codebuild_run_tests_stage["github_repo"]
  github_access_token = var.codebuild_run_tests_stage["github_access_token"]
  github_certificate  = var.codebuild_run_tests_stage["github_certificate"]
  insecure_ssl        = false

  cicd_bucket_id              = var.codebuild_run_tests_stage["cicd_bucket_id"]
  build_image_url             = var.codebuild_run_tests_stage["docker_img_url"]
  build_image_tag             = var.codebuild_run_tests_stage["docker_img_tag"]
  image_pull_credentials_type = var.codebuild_run_tests_stage["docker_img_pull_credentials_type"]

  vpc_id             = var.codebuild_run_tests_stage["vpc_id"]
  subnets_ids        = var.codebuild_run_tests_stage["subnets_ids"]
  security_group_ids = var.codebuild_run_tests_stage["security_group_ids"]

  buildspec_file        = file(var.codebuild_run_tests_stage["buildspec"])
  environment_variables = var.codebuild_run_tests_stage["env_vars"]
}


# ====================================================================================================== #
# Declaration of the module that will create the pipeline (and additional pipeline for ECS applications) #
# ====================================================================================================== #
module "pipeline" {
  source = "git::ssh://git@github.com/tamer84/infra.git//modules/codepipeline?ref=develop"

  application_name = var.pipeline_base_configs["name"]
  bucket_name      = var.pipeline_base_configs["bucket_name"]
  role_arn         = var.pipeline_base_configs["role_arn"]

  source_stage       = local.source_stage
  tests_source_stage = local.tests_source_stage
  build_stage        = local.build_stage
  deploy_stage_ecs   = var.deploy_stage_ecs

  tests_run_stage = local.run_tests_stage
}
