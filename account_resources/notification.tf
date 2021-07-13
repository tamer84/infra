module "vpp_slack_notification" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "~> 4.0"

  sns_topic_name = "vpp_notifications_global"

  lambda_function_name = "vpp-notification-global"

  slack_webhook_url = var.slack_url
  slack_channel     = "p-vpp-notifications"
  slack_username    = "vpp-global-notifications"
  slack_emoji       = ":amz-ws:"
}