resource "aws_sqs_queue" "dlq" {
  name                        = "failures-${terraform.workspace}"
  fifo_queue                  = false
  content_based_deduplication = false
  message_retention_seconds   = 1209600
}
