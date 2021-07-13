resource "aws_docdb_cluster_parameter_group" "vpp-docdb" {
  family      = "docdb3.6"
  name        = terraform.workspace
  description = "docdb cluster parameter group with TLS disabled"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}
