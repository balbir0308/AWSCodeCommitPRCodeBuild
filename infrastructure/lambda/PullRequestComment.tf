data "archive_file" "zip_pullrequestcomment" {
  type        = "zip"
  source_file = "${path.cwd}/lambda/code/PullRequestComment.py"
  output_path = "PullRequestComment.zip"
}

data "aws_iam_policy_document" "policy_trust_pullrequestcomment" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_policy_pullrequestcomment" {
  statement {
    sid = "LogGroupCreation"

    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
    ]
  }

  statement {
    sid = "LogStreamCreation"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.application_name}_pullrequestcomment:*",
    ]
  }

  statement {
    # We don't scope KMS usage since the CMK is only used for artifacts
    sid = "BuildAccess"

    actions = [
      "codebuild:*",
      "codecommit:*"
    ]

    resources = [
      "arn:aws:codecommit:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.application_name}",
      "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/${var.application_name}"
    ]
  }

}

resource "aws_iam_role" "iam_for_lambda_pullrequestcomment" {
  name               = "iam_for_lambda_pullrequestcomment"
  assume_role_policy = data.aws_iam_policy_document.policy_trust_pullrequestcomment.json
  inline_policy {
    name   = "inline"
    policy = data.aws_iam_policy_document.lambda_policy_pullrequestcomment.json
  }
}

resource "aws_lambda_function" "lambda_pullrequestcomment" {
  function_name = "${var.application_name}_pullrequestcomment"
  filename         = data.archive_file.zip_pullrequestcomment.output_path
  source_code_hash = data.archive_file.zip_pullrequestcomment.output_base64sha256
  role    = aws_iam_role.iam_for_lambda_pullrequestcomment.arn
  handler = "index.lambda_handler"
  runtime = "python3.9"
}

