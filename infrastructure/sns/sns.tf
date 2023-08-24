resource "aws_sns_topic" "create_sns" {
  name = "${var.application_name}_SNS"
  display_name = "${var.application_name}_SNS"
  policy = var.policy

  tags = var.common_tags
}