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
