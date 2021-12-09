# --------- CERTIFICATE ---------

# Find a certificate that is issued
data "aws_acm_certificate" "tango" {
  domain   = "tamer84.eu"
  statuses = ["ISSUED"]
}

