variable "project_name" {
  description = "Name of the project that will identify the resources in AWS"
  type        = string
}

variable "cicd_branch" {
  description = "Branch from which the code will be fetched"
  type        = string
}

variable "github_organisation" {
  description = "Organisation in GitHub where the repository is located"
  type        = string
  default     = "vpp"
}

variable "github_repository" {
  description = "Name of the project repository in GitHub"
  type        = string
}

variable "github_access_token" {
  description = "Personal access token to connect CodeBuild with GitHub Enterprise"
  type        = string
}

variable "insecure_ssl" {
  description = "Boolean flag defining in insecure SSL is allowed"
  type        = bool
  default     = false
}

variable "service_role_arn" {
  description = "Service role to be used to run the build"
  type        = string
}

variable "build_timeout" {
  description = "Maximum duration of the build (in minutes)"
  type        = string
  default     = "60"
}

variable "queued_timeout" {
  description = "Maximum time the build stays in the queue to be started (in minutes)"
  type        = string
  default     = "120"
}

variable "cicd_bucket_id" {
  description = "Name of the bucket where the build artifacts should get stored"
  type        = string
}

variable "build_image_url" {
  description = "URL of the image to be used as the base of the build"
  type        = string
}

variable "build_image_tag" {
  description = "Tag of the image to be used as the base of the build"
  type        = string
}

variable "image_pull_credentials_type" {
  description = "Credentials type to pull the base image of the build (SERVICE_ROLE or CODEBUID)"
  type        = string
  default     = "SERVICE_ROLE"
}

variable "github_certificate" {
  description = "Path to the GitHub certificate for SSL connections"
  type        = string
}

variable "environment_variables" {
  description = "List of environment variables to be used in the build"
  type        = list(any)
  default     = []
}

variable "buildspec_file" {
  description = "Path to the buildpec file to be used in the build"
  type        = string
  default     = ""
}

variable "artifact_name" {
  description = "Name of the artifact object on S3"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "ID of the VPC to be used in the CodeBuild job"
  type        = string
}

variable "subnets_ids" {
  description = "Subnets IDs of the VPC used in the CodeBuild job"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs to be used by the CodeBuild job"
  type        = list(string)
}
