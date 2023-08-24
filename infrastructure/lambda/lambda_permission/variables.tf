variable "application_name" {
  type        = string
  description = "Name of application/service built by the pipeline."
}

variable "function_name" {
  type        = string
  description = "Name of the lambda function."
}

variable "cloudwatch_event_rule_arn" {
  type        = string
  description = "Cloudwatch Event Rule Arn."
}