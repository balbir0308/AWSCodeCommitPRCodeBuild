resource "aws_lambda_permission" "lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.cloudwatch_event_rule_arn
  statement_id_prefix = "${var.application_name}_"
}