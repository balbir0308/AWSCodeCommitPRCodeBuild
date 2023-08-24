data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  application_common_name = "tool_test"
  codecommit_branch_name = "main"
  s3_artifact_bucket_name = "tool-artifact-test"

  kms = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/s3"

  common_tags= {
    "name"          = "test"
  }

}
