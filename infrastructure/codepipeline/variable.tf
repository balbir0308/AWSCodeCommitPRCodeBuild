variable "stages" {
  type = list(object({
    name = string,
    actions = list(object({
      name             = string
      category         = string
      owner            = string
      provider         = string
      version          = string
      run_order        = number
      role_arn         = string
      input_artifacts  = list(string)
      output_artifacts = list(string)
      configuration    = map(string)
      region           = string
      namespace        = string
    }))
  }))
  description = "Array of 2 or more pipeline stage blocks.  A stage block contains a 'name' and action block(s).  See [Resource: aws_codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) for documentation about stages and actions."
}

variable "s3_artifact_bucket_bucket" {
  type        = string
  default     = null
  description = "Name of the S3 bucket where artifacts will be stored."
}

variable "s3_artifact_bucket_id" {
  type        = string
  default     = null
  description = "Name of the S3 bucket where artifacts will be stored."
}

variable "s3bucket_arns" {
  type        = list(string)
  default     = []
  description = "(Optional) List of S3 Bucket which CodeBuild has access to."
}

variable "common_tags" {
  type        = map(string)
  description = "Map of tags assigned to taggable resources. Each element in the map is a key=value of an optional tag."
}

variable "pipeline_name" {
  type        = string
  description = "Name of the pipeline."
}

variable "kms_key_id" {
  type        = string
  description = "KMS Key ARN used to encrypt the artifacts in S3. If no value is provided, the organization default key will be used."
  default     = null
}

variable "deployer_cloudformation_cross_account_role_arns" {
  type        = list(string)
  description = "List of ARNs of IAM Roles that are used to deploy the service."
  default     = []
}