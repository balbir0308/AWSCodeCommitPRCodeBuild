resource "aws_cloudwatch_event_target" "target" {
  target_id = var.targetid
  rule      = var.cloudwatch_rule
  arn       = var.arn
  role_arn  = var.role_arn
  input_transformer {
    input_paths = var.input_paths
    input_template = var.input_templates
  }
}