locals {
  event_bus        = "events-${terraform.workspace}"
  notification_bus = "notifications-${terraform.workspace}"
}

resource "null_resource" "create_bus" {
  provisioner "local-exec" {
    command = "aws events create-event-bus --name ${local.event_bus}"
  }
}

resource "null_resource" "create_notification_bus" {
  provisioner "local-exec" {
    command = "aws events create-event-bus --name ${local.notification_bus}"
  }
}
