resource "aws_budgets_budget" "default" {
  name = replace(
    join("-", [local.name_prefix]),
    "_", "-"
  )
  budget_type       = "COST"
  limit_amount      = "20"
  limit_unit        = "USD"
  time_period_start = "2024-03-01_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["hkak03key@gmail.com"]
  }

  dynamic "notification" {
    for_each = [
      80,
      100,
      200,
    ]
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = ["hkak03key@gmail.com"]
    }
  }
}
