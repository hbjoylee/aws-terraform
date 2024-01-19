data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"

  name = "default-vpc"
  cidr = "10.0.0.0/16"

  azs                         = data.aws_availability_zones.available.names
  default_security_group_name = "default-sg"
  public_subnets              = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames        = true
  enable_dns_support          = true
  default_security_group_ingress = [
    {
      description = "allow SSH"
      protocol    = "TCP"
      self        = false
      from_port   = 22
      to_port     = 22
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "allow http"
      protocol    = "TCP"
      self        = false
      from_port   = 80
      to_port     = 80
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "allow https"
      from_port   = 443
      to_port     = 443
      protocol    = "TCP"
      self        = false
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  default_security_group_egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}

resource "aws_launch_template" "default" {
  name = "default_asg_template"
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }

  image_id = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  key_name = var.key_pair

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
  }
}

resource "aws_autoscaling_group" "asg" {
  min_size         = 2
  max_size         = 5
  desired_capacity = 2
  name_prefix      = "myasg-"
  # availability_zones  = data.aws_availability_zones.available.names

  vpc_zone_identifier = module.vpc.public_subnets
  # Launch template
  launch_template {
    id      = aws_launch_template.default.id
    version = aws_launch_template.default.latest_version
  }

  tag {
    key                 = "Name"
    value               = "example-asg"
    propagate_at_launch = true
  }
}
