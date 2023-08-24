data "aws_iam_policy_document" "pipeline_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.pipeline_name}-codepipeline"
  assume_role_policy = data.aws_iam_policy_document.pipeline_assume_role_policy.json

  tags = var.common_tags
}

resource "aws_iam_role_policy" "codepipeline_base" {
  role   = aws_iam_role.codepipeline_role.name
  name   = "base"
  policy = templatefile("${path.module}/templates/codepipeline-role-policy.json.tftpl",{})
}
