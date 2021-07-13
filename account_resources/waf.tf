# ========================================
# MVI Vin2Spec Api Gateway Firewall
# ========================================
locals {
  ip_sets = [
    # Mbio external IP
    "193.161.196.0/23",
    # Daimler IPs
    "53.0.0.0/8"
  ]
}

resource "aws_wafv2_ip_set" "mvi_vin2spec_allowed_ips" {
  name = "mvi_vin2spec_allowed_ips"
  description = "Allowed Inbound IPs"
  scope = "REGIONAL"
  ip_address_version = "IPV4"
  addresses = local.ip_sets
}


resource "aws_wafv2_web_acl" "mvi_vin2spec_waf_acl" {
  depends_on = [ aws_wafv2_ip_set.mvi_vin2spec_allowed_ips ]
  name        = "mvi_vin2spec_waf"
  scope = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name = "mvi_vin2spec_allowed_ip_rule"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.mvi_vin2spec_allowed_ips.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name = "mvi_vin2spec_allowed_ip_metric"
      sampled_requests_enabled = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name = "mvi_vin2spec_acl_metric"
    sampled_requests_enabled = false
  }
}