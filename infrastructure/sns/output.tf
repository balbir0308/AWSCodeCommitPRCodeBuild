output "aws_sns" {
  description = "Object from terraform aws_sns_topic resource."
  value       = aws_sns_topic.create_sns
}