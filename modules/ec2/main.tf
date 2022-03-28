data "template_file" "startup" {
  template = file(var.template_file)
  vars = {
    environment     = terraform.workspace
    server_url      = var.server_url
    private_key_pem = tls_private_key.server-key.private_key_pem
    certificate_pem = var.generate_certificate ? tls_self_signed_cert.server-cert[0].cert_pem : ""
    additional_vars = jsonencode(var.template_vars)
  }
}

data "local_file" "cloud-init" {
  filename = "${path.module}/cloud-init.cfg"
}

data "template_cloudinit_config" "cloud-init-config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "cloud-config.txt"
    content_type = "text/cloud-config"
    content      = data.local_file.cloud-init.content
  }

  part {
    filename     = "userdata.txt"
    content_type = "text/x-shellscript"
    content      = data.template_file.startup.rendered
  }
}

resource "tls_private_key" "server-key" {
  algorithm = "RSA"
  rsa_bits  = "4086"
}

resource "aws_key_pair" "server-key" {
  key_name   = "${var.server_name}-${terraform.workspace}"
  public_key = tls_private_key.server-key.public_key_openssh
}

resource "tls_self_signed_cert" "server-cert" {
  count           = var.generate_certificate ? 1 : 0
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.server-key.private_key_pem

  validity_period_hours = 8760

  subject {
    common_name = var.server_url
  }

  dns_names = [
    var.server_url
  ]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_ebs_volume" "storage" {
  count             = var.create_ebs ? var.amount : 0
  availability_zone = var.availability_zone
  size              = var.storage_size
  encrypted         = true
  type              = var.storage_type
  iops              = 100

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "${var.server_name}-${count.index}-${terraform.workspace}"
  }

  depends_on = [
    aws_instance.server
  ]
}

resource "aws_volume_attachment" "server" {
  count = var.create_ebs ? var.amount : 0

  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.storage[count.index].id
  instance_id = aws_instance.server[count.index].id
}

resource "aws_instance" "server" {
  count                       = var.amount
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.server-key.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_groups
  associate_public_ip_address = var.with_public_ip
  source_dest_check           = false
  user_data                   = data.template_cloudinit_config.cloud-init-config.rendered
  monitoring                  = true
  iam_instance_profile        = var.instance_profile

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 20
    volume_type           = "gp2"
  }

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "${var.server_name}-${count.index}-${terraform.workspace}"
  }
}

resource "aws_route53_record" "server" {
  count           = var.create_dns ? 1 : 0
  allow_overwrite = true
  name            = var.server_url
  type            = "A"
  zone_id         = var.zone_id
  records         = aws_instance.server.*.public_ip
  ttl             = 60
}

resource "aws_route53_record" "server_local" {
  count           = var.create_local_dns ? 1 : 0
  allow_overwrite = true
  name            = "${var.server_name}.${terraform.workspace}"
  type            = "A"
  zone_id         = var.local_zone_id
  records         = aws_instance.server.*.private_ip
  ttl             = 60
}

resource "aws_cloudwatch_metric_alarm" "server_cpu_usage" {
  count                     = var.create_alarms ? var.amount : 0
  alarm_name                = "${var.server_name}_cpu_usage_${terraform.workspace}_${count.index}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ${var.server_name} CPU utilization"
  insufficient_data_actions = []
  alarm_actions             = var.notification_actions
  dimensions = {
    InstanceId = element(aws_instance.server.*.id, count.index)
  }
  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_cloudwatch_metric_alarm" "server_status" {
  count                     = var.create_alarms ? var.amount : 0
  alarm_name                = "${var.server_name}_status_${terraform.workspace}_${count.index}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors ${var.server_name} status"
  insufficient_data_actions = []
  alarm_actions             = var.notification_actions
  dimensions = {
    InstanceId = element(aws_instance.server.*.id, count.index)
  }
  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_cloudwatch_metric_alarm" "server_memory" {
  count                     = var.create_alarms ? var.amount : 0
  alarm_name                = "${var.server_name}_memory_usage_${terraform.workspace}_${count.index}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "mem_used_percent"
  namespace                 = "/servers/${var.server_name}-${terraform.workspace}"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ${var.server_name} memory usage"
  insufficient_data_actions = []
  alarm_actions             = var.notification_actions
  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_cloudwatch_metric_alarm" "server_disk_usage" {
  count                     = var.create_alarms ? var.amount : 0
  alarm_name                = "${var.server_name}_disk_usage_${terraform.workspace}_${count.index}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "disk_used_percent"
  namespace                 = "/servers/${var.server_name}-${terraform.workspace}"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ${var.server_name} memory usage"
  insufficient_data_actions = []
  alarm_actions             = var.notification_actions
  datapoints_to_alarm       = 1
  dimensions = {
    path   = var.storage_path
    device = "nvme1n1"
    fstype = "xfs"
  }
  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "local_file" "server_cert" {
  count    = var.local_output && var.generate_certificate ? 1 : 0
  content  = tls_self_signed_cert.server-cert[count.index].cert_pem
  filename = "${path.module}/output/${terraform.workspace}/${var.server_name}_cert.pem"
}

resource "local_file" "server_key" {
  count           = var.local_output ? 1 : 0
  content         = tls_private_key.server-key.private_key_pem
  file_permission = "0600"
  filename        = "${path.module}/output/${terraform.workspace}/${var.server_name}_key.pem"
}