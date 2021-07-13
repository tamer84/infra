resource "aws_ec2_transit_gateway" "mbio" {
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "mbio"
  }
}

resource "aws_customer_gateway" "mbio" {
  bgp_asn    = 65000
  ip_address = "193.161.199.253"
  type       = "ipsec.1"

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "mbio"
  }
}

resource "aws_vpn_connection" "mbio" {
  customer_gateway_id = aws_customer_gateway.mbio.id
  transit_gateway_id  = aws_ec2_transit_gateway.mbio.id
  type                = "ipsec.1"
  static_routes_only  = true

  tunnel2_ike_versions = [
    "ikev1",
    "ikev2",
  ]

  tunnel2_phase1_dh_group_numbers = [
    2,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
  ]

  tunnel2_phase1_encryption_algorithms = [
    "AES128",
    "AES128-GCM-16",
    "AES256",
    "AES256-GCM-16",
  ]

  tunnel2_phase1_integrity_algorithms = [
    "SHA1",
    "SHA2-256",
    "SHA2-384",
    "SHA2-512",
  ]

  tunnel2_phase2_dh_group_numbers = [
    2,
    5,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
  ]

  tunnel2_phase2_encryption_algorithms = [
    "AES128",
    "AES128-GCM-16",
    "AES256",
    "AES256-GCM-16",
  ]

  tunnel2_phase2_integrity_algorithms = [
    "SHA1",
    "SHA2-256",
    "SHA2-384",
    "SHA2-512",
  ]

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "mbio"
  }
}

data "aws_ec2_transit_gateway_vpn_attachment" "mbio" {
  transit_gateway_id = aws_ec2_transit_gateway.mbio.id
  vpn_connection_id  = aws_vpn_connection.mbio.id
}

resource "aws_ec2_transit_gateway_route" "mbio" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpn_attachment.mbio.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.mbio.association_default_route_table_id
}
