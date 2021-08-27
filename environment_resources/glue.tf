# ========================================
# Athena
# ========================================
resource "aws_glue_catalog_database" "events_database" {
  name = "events_${terraform.workspace}"
}
