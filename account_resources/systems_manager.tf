# ======================================================
# Session manager log to CloudWatch
# ======================================================
resource "aws_cloudwatch_log_group" "session_manager_log" {
  name = var.session_manager_log_group
  tags = {
    Terraform = "true"
  }
}

resource "aws_ssm_document" "session_manager_prefs" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = <<DOC
{
    "schemaVersion": "1.0",
    "description": "Document to hold regional settings for Session Manager",
    "sessionType": "Standard_Stream",
    "inputs": {
        "cloudWatchLogGroupName": "${aws_cloudwatch_log_group.session_manager_log.name}",
        "cloudWatchEncryptionEnabled": false 
    }
}
DOC
}