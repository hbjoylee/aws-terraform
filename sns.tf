resource "aws_sns_topic" "example_asg_scale_up_and_down_topic" {
  name = "example_asg_scale_up_and_down_topic_with_policy"

  display_name = "ASG Scale Up and Down Topic"

}

resource "aws_sns_topic_policy" "asg_scale_policy" {
  arn = aws_sns_topic.example_asg_scale_up_and_down_topic.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__asg_default_policy_ID"

  statement {
    actions = [
      "SNS:Publish"
    ]

    condition {
      values = [
        aws_cloudwatch_metric_alarm.scale_down_alarm.arn,
        aws_cloudwatch_metric_alarm.scale_up_alarm.arn,
      ]
      test     = "ArnEquals"
      variable = "AWS:SourceArn"
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.example_asg_scale_up_and_down_topic.arn,
    ]

    sid = "Allow_Publish_Alarms"
  }
}

resource "aws_sns_topic_subscription" "asg_scale_up_and_down_topic_subscription" {
  topic_arn = aws_sns_topic.example_asg_scale_up_and_down_topic.arn
  protocol  = "email"
  endpoint  = var.sns_email
}