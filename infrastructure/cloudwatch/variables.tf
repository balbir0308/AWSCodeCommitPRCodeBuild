variable "name" {
  type        = string
  description = "Unique name for resources."
}

variable "description" {
  type        = string
  default     = null
  description = "The description of the rule."
}

variable "event_bus_name" {
  type        = string
  default     = null
  description = "The name or ARN of the event bus to associate with this rule. If you omit this, the default event bus is used.."
}

variable "event_pattern" {
  type        = string
  default     = null
  description = "The event pattern described a JSON object. At least one of schedule_expression or event_pattern is required. "
}

variable "is_enabled" {
  type        = bool
  default     = "true"
  description = "(Whether the rule should be enabled."
}

variable "artifacts_encryption_disabled" {
  type        = bool
  default     = false
  description = "(Optional) If set to true, output artifacts will not be encrypted. If type is set to NO_ARTIFACTS then this value will be ignored. Defaults to `true` since it's expected that S3 default encryption is used."
}

variable "role_arn" {
  type        = string
  default     = null
  description = "The Amazon Resource Name (ARN) associated with the role that is used for target invocation."
}

variable "schedule_expression" {
  type        = string
  default     = null
  description = "The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes). At least one of schedule_expression or event_pattern is required. Can only be used on the default event bus."
}

variable "codecommit_arn" {
  type        = string
  description = "Codecommit project ARN"
}

variable "common_tags" {
  type        = map(string)
  description = "Map of tags assigned to taggable resources. Each element in the map is a key=value of an optional tag."
}