resource "aws_cloudwatch_event_rule" "pullrequest" {
  name        = var.name
  description = var.description

  event_bus_name = var.event_bus_name
  event_pattern = var.event_pattern
  is_enabled = var.is_enabled
  role_arn = var.role_arn
  schedule_expression = var.schedule_expression
  tags = var.common_tags

}