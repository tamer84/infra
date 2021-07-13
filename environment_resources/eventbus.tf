locals {
  event_bus        = "vpp-events-${terraform.workspace}"
  notification_bus = "vpp-notifications-${terraform.workspace}"
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
