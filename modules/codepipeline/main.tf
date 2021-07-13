locals {
  previous_workspace = {
    "test" = "dev",
    "int"  = "test"
  }

  # "Dirty" hack to make the trigger between environments to work with the microgateway
  # Microgateway doesn't have a TEST environment properly setup because oneAPI doesn't have a TEST env, only "development", "integration" and "production"
  # Therefore, the trigger after the pipeline runs on DEV should be directly to INT and not to TEST as in all other applications
  previous_pipeline_main         = contains(["test", "int"], terraform.workspace) && length(regexall("microgateway", var.application_name)) == 0 ? replace(aws_codepipeline.pipeline.id, "-${terraform.workspace}", "-${local.previous_workspace[terraform.workspace]}") : ""
  previous_pipeline_microgateway = contains(["int"], terraform.workspace) && length(regexall("microgateway", var.application_name)) > 0 ? replace(aws_codepipeline.pipeline.id, "-${terraform.workspace}", "-dev") : ""
  previous_pipeline              = local.previous_pipeline_main != "" ? local.previous_pipeline_main : local.previous_pipeline_microgateway != "" ? local.previous_pipeline_microgateway : ""

  # We can't use the result of "previous_pipeline" because it depends on resources only known after a "terraform apply"
  # That's why the conditions seem replicated from the conditional assignments above
  create_cw_rule = contains(["test", "int"], terraform.workspace) && length(regexall("microgateway", var.application_name)) == 0 ? true : contains(["int"], terraform.workspace) && length(regexall("microgateway", var.application_name)) > 0 ? true : false

  tests_source_stage = var.tests_source_stage != null ? ["dummy_entry"] : [] # Dummy entry exists for flow control, does not need to be changed
  tests_run_stage    = var.tests_run_stage != null ? [var.tests_run_stage] : []

  deploy_stage_ecs = var.deploy_stage_ecs != null ? [var.deploy_stage_ecs] : []
}

# ============================================================= #
# Event to trigger next env pipeline (DEV -> TEST; TEST -> INT) #
# ============================================================= #
resource "aws_cloudwatch_event_rule" "event_rule" {
  count = local.create_cw_rule ? 1 : 0

  name        = "codepipeline-${var.application_name}-rule"
  description = "CloudWatch event rule to trigger ${var.application_name} pipeline"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.codepipeline"
  ],
  "detail-type": [
    "CodePipeline Pipeline Execution State Change"
  ],
  "detail": {
    "state": [
      "SUCCEEDED"
    ],
    "pipeline": [
      "${local.previous_pipeline}"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "event_target" {
  count = local.create_cw_rule ? 1 : 0

  rule     = aws_cloudwatch_event_rule.event_rule[0].name
  arn      = aws_codepipeline.pipeline.arn
  role_arn = var.role_arn
}

# ===================================================================== #
# Pipeline to build and deploy (and run tests for non-ECS applications) #
# ===================================================================== #
resource "aws_codepipeline" "pipeline" {
  name     = var.application_name
  role_arn = var.role_arn

  artifact_store {
    location = var.bucket_name
    type     = "S3"
  }

  stage {
    name = "Sources"

    action {
      name             = var.source_stage["name"]
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      output_artifacts = ["source_output"]
      version          = "1"

      configuration = {
        ConnectionArn        = var.source_stage["codestar_connection_arn"]
        FullRepositoryId     = var.source_stage["full_repo_id"]
        BranchName           = var.source_stage["branch_name"]
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
        # The "default" workspace is needed for vpp/account_resources
        DetectChanges = contains(["dev", "prod", "default"], terraform.workspace) ? true : false
      }
    }

    dynamic "action" {
      for_each = [for v in local.tests_source_stage : {}]

      content {
        name             = "TestsSource"
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeStarSourceConnection"
        output_artifacts = ["tests_source_output"]
        version          = "1"

        configuration = {
          ConnectionArn        = var.tests_source_stage["codestar_connection_arn"]
          FullRepositoryId     = var.tests_source_stage["full_repo_id"]
          BranchName           = var.tests_source_stage["branch_name"]
          OutputArtifactFormat = "CODEBUILD_CLONE_REF"
          DetectChanges        = false
        }
      }
    }
  }

  stage {
    name = var.build_stage["name"]

    action {
      name             = var.build_stage["name"]
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = length(local.deploy_stage_ecs) != 0 ? ["build_output"] : []
      version          = "1"

      configuration = {
        ProjectName = var.build_stage["project_name"]
      }
    }
  }

  dynamic "stage" {
    for_each = [for v in local.deploy_stage_ecs : {
      name         = v.name
      cluster_name = v.ecs_cluster_arn
      service_id   = v.ecs_service_id
      filename     = v.imagedef_filename
    }]

    content {
      name = stage.value.name

      action {
        name            = stage.value.name
        category        = "Deploy"
        owner           = "AWS"
        provider        = "ECS"
        input_artifacts = ["build_output"]
        version         = "1"

        configuration = {
          ClusterName = stage.value.cluster_name
          ServiceName = stage.value.service_id
          FileName    = stage.value.filename
        }
      }
    }
  }

  dynamic "stage" {
    for_each = [for v in local.tests_run_stage : {
      name         = v.name
      project_name = v.project_name
    }]

    content {
      name = stage.value.name

      action {
        name            = stage.value.name
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = ["tests_source_output"]
        version         = "1"

        configuration = {
          ProjectName = stage.value.project_name
        }
      }
    }
  }
}
