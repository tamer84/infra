# locals {
#   env_stages = [for env in var.infra_pipeline_envs: {
#     name = env
#     plan_vars = jsonencode([
#       {
#         name  = "ACCOUNT_RESOURCES"
#         type  = "PLAINTEXT"
#         value = "false"
#       },
#       {
#         name  = "ENVIRONMENT_RESOURCES_PLAN"
#         type  = "PLAINTEXT"
#         value = "true"
#       },
#       {
#         name  = "ENVIRONMENT"
#         type  = "PLAINTEXT"
#         value = env
#       }
#     ]),
#     apply_vars = jsonencode([
#       {
#         name  = "ACCOUNT_RESOURCES"
#         type  = "PLAINTEXT"
#         value = "false"
#       },
#       {
#         name  = "ENVIRONMENT_RESOURCES_APPLY"
#         type  = "PLAINTEXT"
#         value = "true"
#       },
#       {
#         name  = "ENVIRONMENT"
#         type  = "PLAINTEXT"
#         value = env
#       }

#     ])
#   }]
#   permissions = [
#     "arn:aws:iam::aws:policy/AdministratorAccess"
#   ]
#   account_stage = [
#     {
#       name = "account_resources",
#       plan_vars = jsonencode([
#         {
#           name  = "ENVIRONMENT_RESOURCES"
#           type  = "PLAINTEXT"
#           value = "false"
#         },
#         {
#           name  = "ACCOUNT_RESOURCES_PLAN"
#           type  = "PLAINTEXT"
#           value = "true"
#         },
#         {
#           name  = "ENVIRONMENT"
#           type  = "PLAINTEXT"
#           value = "account_resources"
#         }
#       ]),
#       apply_vars = jsonencode([
#         {
#           name  = "ENVIRONMENT_RESOURCES"
#           type  = "PLAINTEXT"
#           value = "false"
#         },
#         {
#           name  = "ACCOUNT_RESOURCES_APPLY"
#           type  = "PLAINTEXT"
#           value = "true"
#         },
#         {
#           name  = "ENVIRONMENT"
#           type  = "PLAINTEXT"
#           value = "account_resources"
#         }
#       ])
#     }
#   ]
# }

# resource "aws_codecommit_repository" "vpp-infra" {
#   repository_name = "vpp-infra"
#   description     = "Vehicle Product Platform - Infrastructure as Code"
# }

# # ============> Build pipeline
# resource "aws_s3_bucket" "vpp_pipeline_artifacts" {
#   bucket = "vpp-pipeline-artifacts"
#   acl    = "private"
# }

# resource "aws_iam_role" "vpp_pipeline_role" {
#   name = "vpp-pipeline"
#   path = "/service-role/"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "codepipeline.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy" "vpp_pipeline_policy" {
#   name = "vpp_pipeline_policy"
#   role = aws_iam_role.vpp_pipeline_role.id

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect":"Allow",
#       "Action": [
#         "s3:GetObject",
#         "s3:GetObjectVersion",
#         "s3:GetBucketVersioning",
#         "s3:PutObject"
#       ],
#       "Resource": [
#         "${aws_s3_bucket.vpp_pipeline_artifacts.arn}",
#         "${aws_s3_bucket.vpp_pipeline_artifacts.arn}/*"
#       ]
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "codebuild:BatchGetBuilds",
#         "codebuild:StartBuild"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

# //resource "aws_codepipeline" "vpp_infra" {
# //  name     = "vpp-infra"
# //  role_arn = aws_iam_role.vpp_pipeline_role.arn
# //  artifact_store {
# //    location = aws_s3_bucket.vpp_pipeline_artifacts.bucket
# //    type = "S3"
# //  }
# //  stage {
# //    name = "source"
# //    action {
# //      category         = "Source"
# //      configuration    = {
# //        "BranchName"           = "develop"
# //        "PollForSourceChanges" = "false"
# //        "RepositoryName"       = "vpp-infra"
# //      }
# //      input_artifacts  = []
# //      name             = "Source"
# //      output_artifacts = ["SourceArtifact"]
# //      owner            = "AWS"
# //      provider         = "CodeCommit"
# //      run_order        = 1
# //      version          = "1"
# //    }
# //  }
# //
# //  dynamic "stage" {
# //    for_each = flatten([local.account_stage, local.env_stages])
# //    content {
# //        name = stage.value.name
# //        action {
# //          category         = "Build"
# //          configuration    = {
# //            "EnvironmentVariables" = stage.value.plan_vars
# //            "ProjectName" = aws_codebuild_project.vpp-infra.name
# //          }
# //          input_artifacts  = ["SourceArtifact"]
# //          name             = "plan"
# //          output_artifacts = ["plans_${stage.value.name}"]
# //          owner            = "AWS"
# //          provider         = "CodeBuild"
# //          run_order        = 1
# //          version          = "1"
# //        }
# //
# //        action {
# //          category         = "Approval"
# //          configuration    = {
# //            "CustomData"      = "Check output of previous stage to check ."
# //            "NotificationArn" = module.vpp_slack_notification.this_slack_topic_arn
# //          }
# //          name             = "approve"
# //          owner            = "AWS"
# //          provider         = "Manual"
# //          run_order        = 2
# //          version          = "1"
# //        }
# //
# //        action {
# //          category         = "Build"
# //          configuration    = {
# //            "EnvironmentVariables" = stage.value.apply_vars
# //            "PrimarySource"        = "SourceArtifact"
# //            "ProjectName"          = aws_codebuild_project.vpp-infra.name
# //          }
# //          input_artifacts  = [
# //            "plans_${stage.value.name}",
# //            "SourceArtifact",
# //          ]
# //          name             = "apply"
# //          output_artifacts = []
# //          owner            = "AWS"
# //          provider         = "CodeBuild"
# //          run_order        = 3
# //          version          = "1"
# //        }
# //      }
# //  }
# //}

# # ============> Build project
# resource "aws_s3_bucket" "vpp_build_artifacts" {
#   bucket = "vpp-build-artifacts"
#   acl    = "private"
# }

# resource "aws_iam_role" "vpp_build_infra_role" {
#   name = "vpp-terraform-role"
#   path = "/service-role/"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "codebuild.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy" "vpp_build_policy" {
#   name = "vpp_pipeline_policy"
#   role = aws_iam_role.vpp_build_infra_role.id

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect":"Allow",
#       "Action": "*",
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

# resource "aws_codebuild_project" "vpp-infra" {
#   name          = "vpp-infra"
#   build_timeout = "60"
#   service_role  = aws_iam_role.vpp_build_infra_role.arn
#   badge_enabled = true

#   logs_config {
#     cloudwatch_logs {
#       group_name  = "/build/vpp"
#       status      = "ENABLED"
#       stream_name = "infra"
#     }
#   }

#   artifacts {
#     type = "S3"
#     location = aws_s3_bucket.vpp_build_artifacts.bucket
#     packaging = "NONE"
#   }

#   environment {
#     compute_type = "BUILD_GENERAL1_SMALL"
#     image = "736578946942.dkr.ecr.eu-central-1.amazonaws.com/build-image:terraform"
#     type = "LINUX_CONTAINER"
#     image_pull_credentials_type = "SERVICE_ROLE"
#   }

#   source {
#     type                = "CODECOMMIT"
#     git_clone_depth     = 1
#     insecure_ssl        = false
#     location            = aws_codecommit_repository.vpp-infra.clone_url_http
#     report_build_status = false
#   }
# }
