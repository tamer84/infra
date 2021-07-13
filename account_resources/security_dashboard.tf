// Dashboard for aws cloudtrail alarms

locals {
  // TODO log name from output
  dashboard_code = <<EOT
{
    "start": "-PT1H",
    "widgets": [
        {
            "type": "alarm",
            "x": 0,
            "y": 0,
            "width": 24,
            "height": ${(length(local.alarm_list) / 4) * 1.5},
            "properties": {
                "title": "",
                "alarms": [
                    %{for index, alarm in local.alarm_list~}
                      "${aws_cloudwatch_metric_alarm.alarm[index].arn}"
                      %{if length(local.alarm_list) - 1 != index}
                        ,
                      %{endif}
                    %{endfor}
                ]
            }
        },
        %{for index, alarm in local.alarm_list~}
        {
            "type": "log",
            "x": 0,
            "y": ${6 * (index + 1)},
            "width": 24,
            "height": 6,
            "properties": {
                "title" : "${local.alarm_list[index].alarm_name}",
                "query": " SOURCE 'vpp-cloudtrail-logs' \n| filter %{for eventIndex, content in local.alarm_list[index].event_name_list~} eventName == \"${content}\" %{if(length(local.alarm_list[index].event_name_list) - 1) != eventIndex && length(local.alarm_list[index].event_name_list) != 1} or %{endif} %{endfor} %{for queryIndex, query in local.alarm_list[index].additional_filter_pattern.log_insight_query~} %{if(length(local.alarm_list[index].additional_filter_pattern.log_insight_query) - 1) != queryIndex || queryIndex == 0} and %{endif} ${query} %{endfor} \n| fields @timestamp, @message\n| limit 10",
                "region": "eu-central-1",
                "stacked": false,
                "view": "table"
            }
        }
        %{if length(local.alarm_list) - 1 != index}
          ,
        %{endif}
        %{endfor}
    ]
}
EOT
}

resource "aws_cloudwatch_dashboard" "aws_security_dashboard" {
  dashboard_name = "AWS-Security-Alarms"
  dashboard_body = local.dashboard_code

  depends_on = [aws_cloudwatch_metric_alarm.alarm]
}