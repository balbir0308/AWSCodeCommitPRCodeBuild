output "aws_codecommit_repository" {
  description = "Object from terraform aws_codecommit_repository resource."
  value       = aws_codecommit_repository.pipeline_repository
}