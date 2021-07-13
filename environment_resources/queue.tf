resource "aws_sqs_queue" "vpp_dlq" {
  name                        = "vpp-failures-${terraform.workspace}"
  fifo_queue                  = false
  content_based_deduplication = false
  message_retention_seconds   = 1209600
}
