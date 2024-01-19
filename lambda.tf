data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "archive_file" "lambda_refresh_asg_instance" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function"
  output_path = "${path.module}/refresh_asg_instance.zip"
}


resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

data "aws_iam_policy_document" "refresh_asg_instance_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["autoscaling:Describe*", "autoscaling:TerminateInstanceInAutoScalingGroup"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "refresh_asg_instance_policy" {
  name        = "refresh-asg-intance-policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.refresh_asg_instance_policy.json
}

resource "aws_iam_role_policy_attachment" "refresh_asg_instance_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.refresh_asg_instance_policy.arn
}

resource "aws_lambda_function" "refresh_asg_instance" {
  function_name    = var.lambda_function_name
  description      = "Remove all instances in specific autoscaling group"
  filename         = "refresh_asg_instance.zip"
  handler          = "refresh_asg_instance.handler"
  role             = aws_iam_role.iam_for_lambda.arn
  source_code_hash = data.archive_file.lambda_refresh_asg_instance.output_base64sha256
  runtime          = "python3.12"
  logging_config {
    log_format = "Text"
  }
  depends_on = [
    aws_iam_role_policy_attachment.refresh_asg_instance_policy,
    aws_cloudwatch_log_group.lambda_log,
  ]
}

