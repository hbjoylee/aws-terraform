variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_pair" {
  type    = string
  default = "terraform-key"
}

variable "sns_email" {
  type    = string
  default = "example@email.com"
}

variable "lambda_function_name" {
  type    = string
  default = "refresh_autoscaling_instance_lambda_function"
}


variable "asg_name" {
  type    = string
  default = "myasg"
}

# need match metric name and namespace in report_load_metrics.sh
variable "cloudwatch_load_metric_name" {
  type    = string
  default = "LoadAverage5min"
}

# need match metric name and namespace in report_load_metrics.sh
variable "cloudwatch_load_metric_namespace" {
  type    = string
  default = "ServerLoad"
}
