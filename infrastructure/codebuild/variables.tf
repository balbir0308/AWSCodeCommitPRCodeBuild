variable "name" {
  type        = string
  description = "Unique name for resources."
}

variable "deploy_aws_account_ids" {
  type        = list(string)
  default     = []
  description = "List of AWS Account IDs that infrastructure will be deployed in."
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "The KMS Key ID or ARN used to automatically encrypt artifacts. Defaults to `null` since it's expected that S3 default encryption is used."
}

variable "common_tags" {
  type        = map(string)
  description = "Map of tags assigned to taggable resources. Each element in the map is a key=value of an optional tag."
}

variable "vpc_config" {
  type        = list(object({ vpc_id = string, subnets = list(string), security_group_ids = list(string) }))
  default     = []
  description = "(Optional) Enables AWS CodeBuild to access resources in an Amazon VPC."
}

variable "artifacts_type" {
  type        = string
  default     = "NO_ARTIFACTS"
  description = "(Required) The build output artifact's type. Valid values for this parameter are: CODEPIPELINE, NO_ARTIFACTS or S3."
}

variable "artifacts_location" {
  type        = string
  default     = null
  description = "(Optional) Information about the build output artifact location. If type is set to CODEPIPELINE or NO_ARTIFACTS then this value will be ignored. If type is set to S3, this is the name of the output bucket. If path is not also specified, then location can also specify the path of the output artifact in the output bucket."
}

variable "artifacts_encryption_disabled" {
  type        = bool
  default     = false
  description = "(Optional) If set to true, output artifacts will not be encrypted. If type is set to NO_ARTIFACTS then this value will be ignored. Defaults to `true` since it's expected that S3 default encryption is used."
}

variable "source_type" {
  type        = string
  default     = "CODECOMMIT"
  description = "(Required) The type of repository that contains the source code to be built. Valid values for this parameter are: CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET, S3 or NO_SOURCE."
}

variable "source_location" {
  type        = string
  default     = null
  description = "(Optional) The location of the source code from git or s3."
}

variable "source_buildspec" {
  type        = string
  default     = null
  description = "(Optional) The build spec declaration to use for this build project's related builds."
}

variable "source_version" {
  type        = string
  description = "(Optional) Version of the build input to be built for this project. If not specified, the latest version is used. If specifing a branch name, format should be `refs/heads/<branch_name>`."
  default     = null
}

variable "environment_variables" {
  type        = list(object({ name = string, value = string, type = string }))
  default     = []
  description = "(Optional) A list of environment variables to make available to builds for this build project."
}

variable "environment_privileged_mode" {
  type        = bool
  default     = null
  description = "(Optional) If set to true, enables running the Docker daemon inside a Docker container. Defaults to false."
}

variable "environment_image" {
  type        = string
  default     = "aws/codebuild/standard:5.0"
  description = "(Required) The Docker image to use for this build project. Valid values include Docker images provided by CodeBuild (e.g aws/codebuild/standard:2.0), Docker Hub images (e.g. hashicorp/terraform:latest), and full Docker repository URIs such as those for ECR (e.g. 137112412989.dkr.ecr.us-west-2.amazonaws.com/amazonlinux:latest)."
}

variable "environment_compute_type" {
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
  description = "(Required) Information about the compute resources the build project will use. Available values for this parameter are: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM or BUILD_GENERAL1_LARGE. BUILD_GENERAL1_SMALL is only valid if type is set to LINUX_CONTAINER."
}

variable "environment_type" {
  type        = string
  default     = "LINUX_CONTAINER"
  description = "(Required) The type of build environment to use for related builds. Available values are: LINUX_CONTAINER or WINDOWS_CONTAINER."
}

variable "environment_image_pull_credentials_type" {
  type        = string
  default     = "CODEBUILD"
  description = "(Optional) The type of credentials AWS CodeBuild uses to pull images in your build. Available values for this parameter are `CODEBUILD` or `SERVICE_ROLE`. When you use a cross-account or private registry image, you must use `SERVICE_ROLE` credentials. When you use an AWS CodeBuild curated image, you must use `CODEBUILD` credentials. Default to `CODEBUILD`."
}

variable "execution_role_arns" {
  type        = list(string)
  default     = []
  description = "(Optional) List of IAM Roles that CodeBuild can assume. Useful when executing tools or scripts that interact with AWS such as Terraform."
}

variable "s3bucket_arns" {
  type        = list(string)
  default     = []
  description = "(Optional) List of S3 Bucket which CodeBuild has access to."
}

variable "build_timeout" {
  type        = string
  default     = 60
  description = "Number of minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed. The default is 60 minutes."
}

variable "queued_timeout" {
  type        = string
  default     = 480
  description = "Number of minutes, from 5 to 480 (8 hours), a build is allowed to be queued before it times out. The default is 480 mins."
}


