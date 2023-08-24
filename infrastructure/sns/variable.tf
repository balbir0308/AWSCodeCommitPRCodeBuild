variable "common_tags" {
  type        = map(string)
  description = "Map of tags assigned to taggable resources. Each element in the map is a key=value of an optional tag."
}

variable "application_name" {
  type        = string
  description = "Application name."
}

variable "policy" {
  type        = string
  description = "The fully-formed AWS policy as JSON. For more information about building AWS IAM policy documents with Terraform."
  default     = null
}