variable "application_name" {
  description = "Name of the application (e.g. aggregator)"
  type        = string

}

variable "bucket_name" {
  description = "ID (name) of the bucket where the artifacts are stored"
  type        = string
}

variable "role_arn" {
  description = "ARN of the role that should run the pipeline"
  type        = string
}

variable "source_stage" {
  description = "Definition of Source stage configuration"
  type = object({
    name                    = string
    codestar_connection_arn = string # arn:aws:codestar-connections:eu-central-1:736578946942:connection/CONNECTION_ID
    full_repo_id            = string # mboc-dp/repo_name
    branch_name             = string # repo_branch
  })
}

variable "tests_source_stage" {
  description = "Definition of the tests Source stage configuration"
  default     = null
  type = object({
    name                    = string
    codestar_connection_arn = string # arn:aws:codestar-connections:eu-central-1:736578946942:connection/CONNECTION_ID
    full_repo_id            = string # mboc-dp/repo_name
    branch_name             = string # repo_branch
  })
}

variable "build_stage" {
  description = "Definition of Build stage configuration"
  type = object({
    name         = string
    project_name = string
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

variable "tests_run_stage" {
  description = "Definition of the (CodeBuild) stage configuration to run the tests"
  default     = null
  type = object({
    name         = string
    project_name = string
  })
}

