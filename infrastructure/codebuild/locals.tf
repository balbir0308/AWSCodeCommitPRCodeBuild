data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  source_location = var.source_location
}