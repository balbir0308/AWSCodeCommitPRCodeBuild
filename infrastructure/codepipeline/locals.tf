data "aws_region" "current" {}

data "aws_caller_identity" "current" {}



locals {
  kms_key_id = var.kms_key_id
}
