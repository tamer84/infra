resource "aws_ec2_transit_gateway" "dag" {
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  amazon_side_asn = 65501

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "dag"
  }
}

resource "aws_customer_gateway" "dag" {
  bgp_asn    = 31399
  ip_address = "141.113.48.11"
  type       = "ipsec.1"

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "dag"
  }
}

resource "aws_vpn_connection" "dag" {
  customer_gateway_id   = aws_customer_gateway.dag.id
  transit_gateway_id    = aws_ec2_transit_gateway.dag.id
  type                  = "ipsec.1"
  static_routes_only    = false
  tunnel1_inside_cidr   = "169.254.89.136/30"
  tunnel2_inside_cidr   = "169.254.89.200/30"
  tunnel1_preshared_key = var.psk
  tunnel2_preshared_key = var.psk

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "dag"
  }
}


resource "aws_customer_gateway" "dag2" {
  bgp_asn    = 31399
  ip_address = "141.113.48.12"
  type       = "ipsec.1"

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "dag"
  }
}

resource "aws_vpn_connection" "dag2" {
  customer_gateway_id   = aws_customer_gateway.dag2.id
  transit_gateway_id    = aws_ec2_transit_gateway.dag.id
  type                  = "ipsec.1"
  static_routes_only    = false
  tunnel1_inside_cidr   = "169.254.90.8/30"
  tunnel2_inside_cidr   = "169.254.90.72/30"
  tunnel1_preshared_key = var.psk
  tunnel2_preshared_key = var.psk

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "dag"
  }
}


data "aws_ec2_transit_gateway_vpn_attachment" "dag" {
  transit_gateway_id = aws_ec2_transit_gateway.dag.id
  vpn_connection_id  = aws_vpn_connection.dag.id
}

resource "aws_ec2_transit_gateway_route" "dag" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpn_attachment.dag.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.dag.association_default_route_table_id
}