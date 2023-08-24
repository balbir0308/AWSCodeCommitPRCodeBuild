variable "common_tags" {
  type        = map(string)
  description = "Map of tags assigned to taggable resources. Each element in the map is a key=value of an optional tag."
  default = {
    name = "Test"
  }
}

variable "application_name" {
  type        = string
  description = "Name of application/service built by the pipeline."
}