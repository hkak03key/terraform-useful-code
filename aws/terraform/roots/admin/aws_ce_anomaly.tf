# MEMO:
# monitor_dimension が "SERVICE" であるmonitorは1つしか作れない
# そのため、defaultで作成されるリソースを事前に消す必要がある
# https://us-east-1.console.aws.amazon.com/costmanagement/home#/anomaly-detection/
resource "aws_ce_anomaly_monitor" "service" {
  name = replace(
    join("-", [local.name_prefix, "service"]),
    "_", "-"
  )
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}


resource "aws_ce_anomaly_subscription" "service_default" {
  name = replace(
    join("-", [local.name_prefix, "service"]),
    "_", "-"
  )
  frequency = "DAILY"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.service.arn,
  ]

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_PERCENTAGE"
      match_options = ["GREATER_THAN_OR_EQUAL"]
      values        = ["20"]
    }
  }

  subscriber {
    type    = "EMAIL"
    address = "hkak03key@gmail.com"
  }
}
