locals {
  zones = ["a", "b", "c"]
  vpcs_cidr_blocks = {
    "dev"  = "${var.vpcs_cidr_prefix}0${var.vpcs_cidr_suffix}"
    "test" = "${var.vpcs_cidr_prefix}64${var.vpcs_cidr_suffix}"
    "int"  = "${var.vpcs_cidr_prefix}128${var.vpcs_cidr_suffix}"
    "prod" = "${var.vpcs_cidr_prefix}192${var.vpcs_cidr_suffix}"
  }
}

resource "aws_vpc" "vpp" {
  cidr_block           = local.vpcs_cidr_blocks[terraform.workspace]
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "vpp-${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpp.id

  tags = {
    Name        = "vpp-${terraform.workspace}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.vpp.default_route_table_id

  dynamic "route" {
    for_each = var.mbio_subnet
    content {
      cidr_block         = route.value
      transit_gateway_id = data.terraform_remote_state.account_resources.outputs.mbio_transit_gateway.id
    }
  }

  dynamic "route" {
    for_each = var.daimler_subnet
    content {
      cidr_block         = route.value
      transit_gateway_id = data.terraform_remote_state.account_resources.outputs.dag_transit_gateway.id
    }
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "${terraform.workspace}-default"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}


resource "aws_cognito_user_pool_client" "lb_client" {
  name                                 = "lb-client-${terraform.workspace}"
  user_pool_id                         = data.terraform_remote_state.account_resources.outputs.user_pool.id
  generate_secret                      = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
  callback_urls                        = ["https://${terraform.workspace}.vpp.mercedes-benz.io/oauth2/idpresponse"]
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows                  = ["ADMIN_NO_SRP_AUTH"]
}

resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name = "vpc_flow_log-${terraform.workspace}"
  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_flow_log" "vpc_flow_log_cw" {
  iam_role_arn    = data.terraform_remote_state.account_resources.outputs.vpc_flow_log_cloudwatch_access_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpp.id

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}
