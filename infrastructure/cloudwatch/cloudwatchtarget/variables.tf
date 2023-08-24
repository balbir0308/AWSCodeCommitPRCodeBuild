variable "targetid" {
  type        = string
  default     = null
  description = "The unique target assignment ID. If missing, will generate a random, unique id."
}

variable "role_arn" {
  type        = string
  default     = null
  description = "The Amazon Resource Name (ARN) of the IAM role to be used for this target when the rule is triggered."
}

variable "cloudwatch_rule" {
  type        = string
  description = "The name of the rule you want to add targets to."
}

variable "arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the target."
}

variable "input_paths" {
  type        = map
  default     = {
    instance = "$.detail.instance",
    status   = "$.detail.status",
  }
  description = "Key value pairs specified in the form of JSONPath."
}

variable "input_templates" {
  type        = string
  default     = <<EOF
                {
                  "instance_id": <instance>,
                  "instance_status": <status>
                }
                EOF
  description = "Template to customize data sent to the target."
}