

data "aws_iam_policy_document" "codebuild_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_assume_event_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "invoke_codebuild" {
  statement {
    actions = ["codebuild:StartBuild"]

    resources = [
      "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/${var.name}",
    ]
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "${var.name}-codebuild"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy.json
  tags = var.common_tags
}

resource "aws_iam_role" "invoke-codebuild" {
  name               = "${var.name}-invoke-codebuild"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_event_role_policy.json
  tags = var.common_tags
}

locals {
  codecommit_arn = var.source_type == "CODECOMMIT" ? ["arn:aws:codecommit:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.source_location}"] : []
}

data "aws_iam_policy_document" "codebuild_base" {
  statement {
    sid = "Logging"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.name}",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.name}:*",
    ]
  }

  statement {
    sid = "SAMValidatePrivileges"

    actions = [
      "iam:ListPolicies",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    # We don't scope KMS usage since the CMK is only used for artifacts
    sid = "CentralInstallers"

    actions = [
      "s3:GetObject",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "ssm:Describe*",
      "ssm:Get*",
      "ssm:List*"
    ]

    resources = [
      "*"
    ]
  }
  statement {
    sid = "UploadReports"

    actions = [
      "codebuild:BatchPutCodeCoverages",
      "codebuild:BatchPutTestCases",
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
    ]

    resources = [
      "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report-group/${var.name}-*",
    ]
  }

  dynamic "statement" {
    for_each = var.s3bucket_arns
    content {
      actions = [
        "s3:GetObject",
        "s3:List*",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ]
      resources = [
        "${statement.value}",
        "${statement.value}/*",
      ]
    }
  }

  dynamic "statement" {
    for_each = local.codecommit_arn
    content {
      sid = "AllowPullCodeCommit"
      actions = [
        "codecommit:GitPull",
      ]

      resources = [
        statement.value,
      ]
    }
  }
}

resource "aws_iam_role_policy" "codebuild_base" {
  role   = aws_iam_role.codebuild.name
  name   = "${var.name}_base"
  policy = data.aws_iam_policy_document.codebuild_base.json
}

resource "aws_iam_role_policy" "invoke_codebuild_role_policy" {
  role   = aws_iam_role.invoke-codebuild.name
  name   = "${var.name}_Invoke_CodeBuild_Policy"
  policy = data.aws_iam_policy_document.invoke_codebuild.json
}

