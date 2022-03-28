output "aws_lb" {
  description = "Load balance resource"
  value       = aws_lb.lb
}
output "target_groups" {
  description = "Target group resources attached to the load balancer"
  value       = aws_lb_target_group.lb_target_group
}

output "route53_record" {
  description = "DNS Record from Route53"
  value       = aws_route53_record.route53_record
}


output "aws_lb_listener" {
  description = "Load balance listener"
  value       = aws_lb_listener.lb_listener
}