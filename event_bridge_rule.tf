resource "aws_cloudwatch_event_rule" "refresh_asg_instance_rule" {
  name        = "refresh-asg-group-rule"
  description = "terminate all instance in asg"
  # 12AM UTC
  schedule_expression = "cron(0 0 * * ? *)"
}

resource "aws_cloudwatch_event_target" "refresh_asg_instance_target" {
  arn  = aws_lambda_function.refresh_asg_instance.arn
  rule = aws_cloudwatch_event_rule.refresh_asg_instance_rule.name
  input = jsonencode(
    {
      region                 = var.region
      autoscaling_group_name = aws_autoscaling_group.asg.name
    }
  )
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.refresh_asg_instance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.refresh_asg_instance_rule.arn
}
