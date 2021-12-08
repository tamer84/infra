# Load Balancer
resource "aws_lb" "lb" {

  name               = "${var.lb_name}-${terraform.workspace}"
  subnets            = var.is_publicly_accessible ? var.public_subnets : var.private_subnets
  load_balancer_type = var.lb_type
  security_groups    = var.lb_security_groups
  internal           = var.is_publicly_accessible ? false : true

  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_lb_listener" "lb_listener" {
  for_each = var.lb_listeners

  load_balancer_arn = aws_lb.lb.id
  protocol          = each.value["protocol"]
  port              = each.value["protocol"] == "TLS" ? "443" : each.value["port"]
  certificate_arn   = each.value["protocol"] == "TLS" ? each.value["certificate_arn"] : ""
  ssl_policy        = each.value["protocol"] == "TLS" ? "ELBSecurityPolicy-TLS-1-2-Ext-2018-06" : ""

  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group[var.default_service_name].id
    type             = "forward"
  }

  depends_on = [aws_lb_target_group.lb_target_group]
}

resource "aws_lb_target_group" "lb_target_group" {
  for_each    = var.target_groups
  name        = "${each.key}-${terraform.workspace}"
  port        = each.value["application_port"]
  protocol    = each.value["protocol"]
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
    timeout             = 6
    matcher             = "200-399"
    path                = each.value["health_endpoint"]
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  stickiness {
    type    = "source_ip"
    enabled = false
  }
}

locals {
  // Remove default service element
  non_default_target_groups = { for k, v in var.target_groups : k => v if !contains([var.default_service_name], k) }
  listener_target_group_combination = {
    for pair in setproduct(keys(aws_lb_listener.lb_listener), keys(local.non_default_target_groups)) :
    join("-", pair) => {
      target_key : pair[1]
      target : local.non_default_target_groups[pair[1]],
      listener : aws_lb_listener.lb_listener[pair[0]].arn
    }
  }
}

resource "aws_lb_listener_rule" "config" {
  for_each = local.listener_target_group_combination

  // Allows for path redirect
  listener_arn = each.value["listener"]
  priority     = each.value["target"]["priority"]
  action {
    type             = each.value["target"]["action"]
    target_group_arn = aws_lb_target_group.lb_target_group[each.value["target_key"]].arn
  }

  condition {
    path_pattern {
      values = [each.value["target"]["path"]]
    }
  }
}


# Route53
resource "aws_route53_record" "route53_record" {
  zone_id = var.zone_id
  name    = terraform.workspace == "prod" ? "${var.lb_name}.tango.tamerhusnu.com" : "${var.lb_name}.${terraform.workspace}.tango.tamerhusnu.com"
  type    = "A"

  alias {
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
    evaluate_target_health = true
  }
}
