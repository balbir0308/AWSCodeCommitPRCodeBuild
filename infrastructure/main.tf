module "codecommit" {
  source = "./codecommit"
  common_tags= local.common_tags
  application_name = local.application_common_name
}

module "codebuild" {
  source = "./codebuild"
  kms_key_id = local.kms
  name = local.application_common_name
  common_tags= local.common_tags
  artifacts_type = "NO_ARTIFACTS"
  source_type = "CODECOMMIT"
  source_buildspec = "buildspec.yml"
  source_version = "refs/heads/${local.codecommit_branch_name}"
  source_location = module.codecommit.aws_codecommit_repository.repository_name
}


module "lambda_build" {
  source = "./lambda"
  application_name = local.application_common_name
}

module "cloudwatch_pullrequestcomment" {
  source = "./cloudwatch"
  name = "${local.application_common_name}_dry_run_rule"
  description = "Trigger notifications based on CodeCommit PullRequests"
  event_bus_name= "default"
  event_pattern = <<EOF
                    {
                      "source": [
                        "aws.codecommit"
                      ],
                      "detail-type": [
                        "CodeCommit Pull Request State Change"
                      ],
                      "resources": [
                        "${module.codecommit.aws_codecommit_repository.arn}"
                      ],
                      "detail": {
                        "event": [
                          "pullRequestSourceBranchUpdated",
                          "pullRequestCreated"
                        ]
                      }
                    }
                  EOF
  codecommit_arn = module.codecommit.aws_codecommit_repository.arn
  common_tags    = local.common_tags
}

module "cloudwatch_target_pullrequestcomment_lambda" {
  source = "./cloudwatch/cloudwatchtarget"
  arn = module.lambda_build.lambda_pullrequestcomment.arn
  cloudwatch_rule = module.cloudwatch_pullrequestcomment.aws_cloudwatch_event_rule.id
}

module "cloudwatch_target_pullrequestcomment_codebuild" {
  source = "./cloudwatch/cloudwatchtarget"
  arn = module.codebuild.codebuild_project_arn
  role_arn = module.codebuild.invoke_codebuild_role.arn
  input_paths = {
    destinationCommit = "$.detail.destinationCommit",
    pullRequestId = "$.detail.pullRequestId",
    repositoryName = "$.detail.repositoryNames[0]",
    sourceCommit = "$.detail.sourceCommit",
    sourceVersion = "$.detail.sourceCommit"
  }
  input_templates = <<EOF
                      {
                        "sourceVersion": <sourceVersion>,
                        "artifactsOverride": {"type": "NO_ARTIFACTS"},
                        "environmentVariablesOverride": [
                           {
                               "name": "pullRequestId",
                               "value": <pullRequestId>,
                               "type": "PLAINTEXT"
                           },
                           {
                               "name": "repositoryName",
                               "value": <repositoryName>,
                               "type": "PLAINTEXT"
                           },
                           {
                               "name": "sourceCommit",
                               "value": <sourceCommit>,
                               "type": "PLAINTEXT"
                           },
                           {
                               "name": "destinationCommit",
                               "value": <destinationCommit>,
                               "type": "PLAINTEXT"
                           }
                        ]
                      }
                    EOF
  cloudwatch_rule = module.cloudwatch_pullrequestcomment.aws_cloudwatch_event_rule.id
}

module "update_pullrequestcomment_lambda_permission" {
  source = "./lambda/lambda_permission"

  application_name          = local.application_common_name
  cloudwatch_event_rule_arn = module.cloudwatch_pullrequestcomment.aws_cloudwatch_event_rule.arn
  function_name             = module.lambda_build.lambda_pullrequestcomment.function_name
}

module "cloudwatch_pullrequestcodebuildupdate" {
  source = "./cloudwatch"
  name = "${local.application_common_name}_monitor_codebuild_status"
  description = "Post CodeBuild Status"
  event_bus_name= "default"
  event_pattern = <<EOF
                    {
                      "source": [
                        "aws.codebuild"
                      ],
                      "detail-type": [
                        "CodeBuild Build State Change"
                      ],
                      "detail": {
                        "build-status": [
                          "SUCCEEDED",
                          "FAILED"
                        ]
                      }
                    }
                  EOF
  codecommit_arn = module.codecommit.aws_codecommit_repository.arn
  common_tags    = local.common_tags
}

module "cloudwatch_target_pullrequestcodebuildupdate_lambda" {
  source = "./cloudwatch/cloudwatchtarget"
  arn = module.lambda_build.lambda_pullrequestcodebuildupdate.arn
  cloudwatch_rule = module.cloudwatch_pullrequestcodebuildupdate.aws_cloudwatch_event_rule.id
}

module "update_pullrequestcodebuildupdate_lambda_permission" {
  source = "./lambda/lambda_permission"

  application_name          = local.application_common_name
  cloudwatch_event_rule_arn = module.cloudwatch_pullrequestcodebuildupdate.aws_cloudwatch_event_rule.arn
  function_name             = module.lambda_build.lambda_pullrequestcodebuildupdate.function_name
}

resource "aws_s3_bucket" "artifactory-bucket" {
  bucket = "${local.s3_artifact_bucket_name}"
  tags = local.common_tags
}

module "merge_build_codepipelie" {
  source = "./codepipeline"
  s3_artifact_bucket_bucket =  aws_s3_bucket.artifactory-bucket.id
  kms_key_id = ""
  pipeline_name = local.application_common_name
  common_tags= local.common_tags
  stages = [
    (
    {
      name = "Source",
      actions = [
        (
        {
          name = "${local.application_common_name}-monitor-source-change"
          category = "Source"
          owner = "AWS"
          provider = "CodeCommit"
          version = "1"
          run_order: 1
          output_artifacts = [
            "source_output"]
          input_artifacts: []
          configuration = {
            RepositoryName = module.codecommit.aws_codecommit_repository.repository_name
            BranchName = local.codecommit_branch_name
            PollForSourceChanges: "true"
          }
          namespace = null
          region = null
          role_arn = null
        }
        )
      ]
    }
    ),
    (
    {
      name = "${local.application_common_name}-Build-Dev",
      actions = [
        (
        {
          name = "${local.application_common_name}-Build-Dev"
          category = "Build"
          owner = "AWS"
          provider = "CodeBuild"
          version = "1"
          run_order= 1
          output_artifacts = [
            "BuildArtifactDev"
          ]
          input_artifacts= [
            "source_output"
          ]
          configuration = {
            ProjectName = module.codebuild.codebuild_project.name
            EnvironmentVariables = jsonencode([
              {
                name = "provision"
                value = "true"
                type = "PLAINTEXT"
              }
            ])
          }
          namespace = null
          region = null
          role_arn = null
        }
        )
      ]
    }
    )
  ]
}

module "cloudwatch_trigger_merge_build_codepipelie" {
  source = "./cloudwatch"
  name = "${local.application_common_name}_trigger_codepipeline"
  description = "Amazon CloudWatch Events rule to automatically start your pipeline when a change occurs in the AWS CodeCommit source repository and branch. Deleting this may prevent changes from being detected in that pipeline."
  event_bus_name= "default"
  event_pattern = <<EOF
                    {
                      "detail":{
                          "event":[
                              "referenceCreated",
                              "referenceUpdated"
                           ],
                           "referenceName":["${local.codecommit_branch_name}"],
                           "referenceType":["branch"]
                      },
                      "detail-type":[
                          "CodeCommit Repository State Change"
                      ],
                      "resources":[
                          "${module.codecommit.aws_codecommit_repository.arn}"
                      ],
                      "source":["aws.codecommit"]
                  }
                  EOF
  codecommit_arn = ""
  common_tags    = local.common_tags
}

module "cloudwatch_trigger_merge_build_codepipelie_target" {
  source = "./cloudwatch/cloudwatchtarget"
  arn = module.merge_build_codepipelie.aws_codepipeline.arn
  role_arn = module.merge_build_codepipelie.aws_codepipeline_iam.arn
  cloudwatch_rule = module.cloudwatch_trigger_merge_build_codepipelie.aws_cloudwatch_event_rule.id
}

module "merge_build_codepipelie_sns_topic" {
  source           = "./sns"
  application_name = local.application_common_name
  common_tags      = local.common_tags
  policy = "{\"Version\":\"2012-10-17\",\"Id\":\"__default_policy_ID\",\"Statement\":[{\"Sid\":\"${local.application_common_name}CodeCommit\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"codecommit.amazonaws.com\"},\"Action\":\"sns:Publish\",\"Resource\":\"${module.codecommit.aws_codecommit_repository.arn}\"},{\"Sid\":\"AWSEvents_${local.application_common_name}CodepipelineNotification_Idad31820d-1cea-46e5-a288-76393c910c79\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"events.amazonaws.com\"},\"Action\":\"sns:Publish\",\"Resource\":\"arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${local.application_common_name}_SNS\"}]}"
}

module "cloudwatch_trigger_merge_build_codepipelie_notification" {
  source = "./cloudwatch"
  name = "${local.application_common_name}_trigger_codepipeline_event"
  description = "Trigger notifications based on pipeline state changes."
  event_bus_name= "default"
  event_pattern = <<EOF
                    {
                      "source": [
                        "aws.codepipeline"
                      ],
                      "resources": [
                        "${module.merge_build_codepipelie.aws_codepipeline.arn}"
                      ],
                      "detail-type": [
                        "CodePipeline Stage Execution State Change"
                      ],
                      "detail": {
                        "state": [
                          "STARTED",
                          "FAILED",
                          "SUCCEEDED"
                        ]
                      }
                    }
                  EOF
  codecommit_arn = ""
  common_tags    = local.common_tags
}

module "cloudwatch_trigger_codepipeline_notification_target" {
  source = "./cloudwatch/cloudwatchtarget"
  arn = module.merge_build_codepipelie_sns_topic.aws_sns.arn
  cloudwatch_rule = module.cloudwatch_trigger_merge_build_codepipelie_notification.aws_cloudwatch_event_rule.id
}