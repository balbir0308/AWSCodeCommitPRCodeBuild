output "aws_codepipeline" {
  description = "Object from terraform aws_codepipeline resource."
  value       = aws_codepipeline.codepipeline
}

output "aws_codepipeline_iam" {
  description = "IAM Service Role for Codepipeline."
  value       = aws_iam_role.codepipeline_role
}