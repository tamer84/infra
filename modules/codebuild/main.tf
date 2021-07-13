resource "aws_codebuild_source_credential" "github_access_token" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB_ENTERPRISE"
  token       = var.github_access_token

}

resource "aws_codebuild_project" "codebuild" {
  name           = var.project_name
  description    = "${var.project_name} codebuild project"
  build_timeout  = var.build_timeout
  queued_timeout = var.queued_timeout
  service_role   = var.service_role_arn

  artifacts {
    type                   = "S3"
    override_artifact_name = false
    location               = var.cicd_bucket_id
    packaging              = "ZIP"
    name                   = var.artifact_name == "" ? var.project_name : var.artifact_name
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "${var.build_image_url}:${var.build_image_tag}"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = var.image_pull_credentials_type
    privileged_mode             = true
    certificate                 = var.github_certificate

    dynamic "environment_variable" {
      for_each = [for v in var.environment_variables : {
        name  = v.name
        value = v.value
      }]

      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      status = "DISABLED"
    }
  }

  source {
    type            = "GITHUB_ENTERPRISE"
    location        = "https://git.daimler.com/${var.github_organisation}/${var.github_repository}.git"
    git_clone_depth = 999
    insecure_ssl    = var.insecure_ssl
    buildspec       = var.buildspec_file

    auth {
      type     = "OAUTH"
      resource = aws_codebuild_source_credential.github_access_token.arn
    }

    git_submodules_config {
      fetch_submodules = false
    }
  }

  source_version = var.cicd_branch

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.subnets_ids
    security_group_ids = var.security_group_ids
  }

  tags = {
    Terraform = "true"
  }
}
