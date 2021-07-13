variable "codebuild_build_stage" {
  description = "Configuration values for the Build phase CodeBuild job"
  type = object({
    project_name                     = string
    github_branch                    = string
    github_organisation              = string
    github_repo                      = string
    github_access_token              = string
    github_certificate               = string
    service_role_arn                 = string
    cicd_bucket_id                   = string
    vpc_id                           = string
    subnets_ids                      = list(string)
    security_group_ids               = list(string)
    docker_img_url                   = string
    docker_img_tag                   = string
    docker_img_pull_credentials_type = string # "SERVICE_ROLE" or "CODEBUILD"
    buildspec                        = string
    env_vars                         = list(map(any))
  })
}

variable "codebuild_run_tests_stage" {
  description = "Configuration values for the CodeBuild job that runs the tests"
  default     = null
  type = object({
    project_name                     = string
    github_branch                    = string
    github_organisation              = string
    github_repo                      = string
    github_access_token              = string
    github_certificate               = string
    service_role_arn                 = string
    cicd_bucket_id                   = string
    vpc_id                           = string
    subnets_ids                      = list(string)
    security_group_ids               = list(string)
    docker_img_url                   = string
    docker_img_tag                   = string
    docker_img_pull_credentials_type = string # "SERVICE_ROLE" or "CODEBUILD"
    buildspec                        = string
    env_vars                         = list(map(any))
  })
}

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar connection to Daimler Github"
  type        = string
}

variable "pipeline_base_configs" {
  description = "Base configuration for the pipeline"
  type = object({
    name        = string
    bucket_name = string
    role_arn    = string
  })
}

variable "deploy_stage_ecs" {
  description = "Definition of Deploy stage configuration for ECS"
  default     = null
  type = object({
    name              = string
    ecs_cluster_arn   = string
    ecs_service_id    = string
    imagedef_filename = string
  })
}
