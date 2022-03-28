# CICD module - Technical Documentation

This module allows for the creation of all the necessary resources for our CICD setup explained [here]().

It allows for 2 kinds of pipelines:
* Pipeline to build and deploy Lambda-based applications
* Pipeline to build and deploy Fargate-based applications

The modules uses two additional modules to create and manage:
* CodePipeline resources: `codepipeline` module
* CodeBuild resources: `codebuild` module

## Integrations

The integration is made by defining a set of parameters:
| Variable                  | Type   | Mandatory | Comment                                                                                                                                                                                                       |
|---------------------------|--------|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| codestar_connection_arn   | string | yes       | The ARN of the CodeStar connection (check https://eu-central-1.console.aws.amazon.com/codesuite/settings/connections?region=eu-central-1&connections-meta=eyJmIjp7InRleHQiOiIifSwicyI6e30sIm4iOjIwLCJpIjowfQ) |
| pipeline_base_configs     | object | yes       | The basic configuration of the pipeline to be created (see below)                                                                                                                                             |
| codebuild_build_stage     | object | yes       | The configuration values for the CodeBuild job used to build the application and run Terraform (in case of Lambda applications, it also deploys the new version)                                              |
| codebuild_run_tests_stage | object | no        | The configuration values for the CodeBuild job used to run the tests. Can be omitted or set to "null" if no tests need to be run.                                                                             |
| deploy_stage_ecs          | object | no        | The configuration values for the (optional) pipeline stage that deploys an application to Fargate (see below). Only needed if the application is hosted on Fargate.                                           |

#### pipeline_base_configs
| Variable    | Type   | Mandatory | Comment                                                                                                                                                                                                      |
|-------------|--------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name        | string | yes       | The name to be given to the pipeline                                                                                                                                                                         |
| bucket_name | string | yes       | The CICD bucket, which is defined in `infra/environment_resources` and usually takes the value of `data.terraform_remote_state.environment_resources.outputs.cicd_bucket.id`                             |
| role_arn    | string | yes       | The ARN of the role that is used to run the pipeline, which is defined in `infra/account_resources` and usually takes the value of `data.terraform_remote_state.account_resources.outputs.cicd_role.arn` |

#### codebuild_build_stage
| Variable                         | Type         | Mandatory | Comment                                                                                                                                                                                                                                                                            |
|----------------------------------|--------------|-----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| project_name                     | string       | yes       | The name to be given to the CodeBuild job                                                                                                                                                                                                                                          |
| github_branch                    | string       | yes       | The GitHub branch where the source code should be pulled from                                                                                                                                                                                                                      |
| github_repo                      | string       | yes       | The GitHub repository name                                                                                                                                                                                                                                                         |
| github_certificate               | string       | yes       | The GitHub certificate, which exists in S3 and usually takes the value of `"${data.terraform_remote_state.environment_resources.outputs.cicd_bucket.arn}/${data.terraform_remote_state.environment_resources.outputs.github_cert.id}"`                          |
| service_role_arn                 | string       | yes       | The ARN of the role that is used to run the pipeline, which is defined in `infra/account_resources` and usually takes the value of `data.terraform_remote_state.account_resources.outputs.cicd_role.arn`                                                                       |
| cicd_bucket_id                   | string       | yes       | The CICD bucket, which is defined in `infra/environment_resources` and usually takes the value of `data.terraform_remote_state.environment_resources.outputs.cicd_bucket.id`                                                                                                   |
| vpc_id                           | string       | yes       | The ID of the VPC to be used, which is defined in `infra/environment_resources` and usually takes the value of `data.terraform_remote_state.environment_resources.outputs.vpc.id`                                                                                              |
| subnets_ids                      | list(string) | yes       | The IDs of the subnets to be used. These should be the private subnets, which are defined in `infra/environment_resources` and usually take the value of `data.terraform_remote_state.environment_resources.outputs.private-subnet.*.id`                                       |
| security_group_ids               | list(string) | yes       | The IDs of the security groups to be used. These should be only internal security groups, and the one we use is defined in `infra/environment_resources` and usually takes the value of `[data.terraform_remote_state.environment_resources.outputs.group_internal_access.id]` |
| docker_img_url                   | string       | yes       | The URL of the Docker image used to run the CodeBuild job. To use our custom Docker image, please use `data.terraform_remote_state.terraform_build_image_resources.outputs.ecr_repository.repository_url`                                                                          |
| docker_img_tag                   | string       | yes       | The image tag of the Docker image. Our custom Docker image is tagged with "latest".                                                                                                                                                                                                |
| docker_img_pull_credentials_type | string       | yes       | The credentials type. To use our Docker image, use `SERVICE_ROLE`. To use a Docker image provided by CodeBuild, use `CODEBUILD`.                                                                                                                                                   |
| buildspec                        | string       | yes       | The full name of the buildspec YAML file to be used in the CodeBuild job                                                                                                                                                                                                           |
| env_vars                         | list(map)    | no        | The environment variables to be used in the CodeBuild job. This is a list of maps, one map per environment variable, with 2 keys: a `name`, which is the name of the environment variable, and a `value`, which is the value of the environment variable.                          |

#### codebuild_run_tests_stage
This has the same structure as `codebuild_build_stage` explained above.

#### deploy_stage_ecs
| Variable          | Type   | Mandatory | Comment                                                                                                                                                                   |
|-------------------|--------|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name              | string | yes       | The name to be given to the deploy step in the pipeline                                                                                                                   |
| ecs_cluster_arn   | string | yes       | The ARN of the ECS cluster running the Fargate application                                                                                                                |
| ecs_service_id    | string | yes       | The ID of the service running on the ECS cluster                                                                                                                          |
| imagedef_filename | string | yes       | The name of the file with the image URL, which is also passed as an environment variable in the build CodeBuild job set using `codebuild_build_stage` (see example below) |
