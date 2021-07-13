# ========================================
# Athena
# ========================================
resource "aws_glue_catalog_database" "events_database" {
  name = "vpp_events_${terraform.workspace}"
}