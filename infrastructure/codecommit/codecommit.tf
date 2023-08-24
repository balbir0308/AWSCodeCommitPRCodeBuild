resource "aws_codecommit_repository" "pipeline_repository" {
  repository_name = var.application_name
  tags = var.common_tags
}