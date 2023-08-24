
resource "aws_codebuild_project" "main" {
  name         = var.name
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type                = var.artifacts_type
    location            = var.artifacts_location
    encryption_disabled = var.artifacts_encryption_disabled
  }

  build_timeout               = var.build_timeout
  queued_timeout              = var.queued_timeout

  environment {
    compute_type                = var.environment_compute_type
    image                       = var.environment_image
    type                        = var.environment_type
    privileged_mode             = var.environment_privileged_mode
    image_pull_credentials_type = var.environment_image_pull_credentials_type

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }

  encryption_key = var.kms_key_id

  source {
    type      = var.source_type
    location  = local.source_location
    buildspec = var.source_buildspec
  }

  source_version = var.source_version

  dynamic "vpc_config" {
    for_each = var.vpc_config
    content {
      vpc_id             = vpc_config.value.vpc_id
      subnets            = vpc_config.value.subnets
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tags = var.common_tags
}
