locals {
  target_groups = { for k, v in var.ecs_services : k => v.target_group }
}

# ======== Load Balance Service ========
module "lb" {
  source = "git::ssh://git@git.daimler.com/mboc-dp/infra.git//modules/lb?ref=develop"

  lb_security_groups     = var.lb_security_groups
  is_publicly_accessible = var.is_publicly_accessible
  lb_type                = var.lb_type
  lb_name                = var.cluster_name
  private_subnets        = var.private_subnets
  public_subnets         = var.public_subnets
  vpc_id                 = var.vpc_id
  lb_listeners           = var.lb_listeners
  target_groups          = local.target_groups
  default_service_name   = var.default_ecs_service_name
  zone_id                = var.zone_id
}

# ECS Cluster for service separation
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.cluster_name}-cluster-${terraform.workspace}"
}

# CloudWatch Log group
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "/ecs/${var.cluster_name}-${terraform.workspace}"
}

# IAM Role for the fargate tasks
data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

# Application Task Definition
resource "aws_ecs_task_definition" "task-definition" {
  for_each                 = var.ecs_services
  family                   = "${each.key}-${terraform.workspace}"
  task_role_arn            = each.value.task_role
  container_definitions    = var.container_definitions[each.key]
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  cpu                      = each.value.cpu
  memory                   = each.value.memory
}

# Fargate Service
resource "aws_ecs_service" "ecs_service" {
  for_each        = var.ecs_services
  name            = "${each.key}-${terraform.workspace}"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task-definition[each.key].arn
  launch_type     = "FARGATE"
  desired_count   = each.value.desired_count

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = var.fargate_security_groups
    assign_public_ip = "true"
  }

  load_balancer {
    target_group_arn = module.lb.target_groups[each.key].arn
    container_name   = "${each.key}-${terraform.workspace}"
    container_port   = module.lb.target_groups[each.key].port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.discovery_service[each.key].arn
  }

  deployment_maximum_percent         = 300
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 120

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_ecs_cluster.ecs_cluster, module.lb]
}

resource "aws_service_discovery_service" "discovery_service" {
  for_each = var.ecs_services
  name     = "${each.key}-${terraform.workspace}"

  dns_config {
    namespace_id = var.dns_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}
