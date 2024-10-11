terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "sa-east-1"
}
variable "aws_region" {
  default = "sa-east-1"  # Change to your preferred region
}

variable "instance_type" {
  default = "t2.micro"   # Free Tier eligible instance type
}

data "aws_ami" "ubuntu" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]  # Canonical's AWS Account ID (Ubuntu official)
}
resource "aws_instance" "app_server" {
  ami             = data.aws_ami.ubuntu.id  # Dynamically selected Ubuntu AMI
  instance_type   = var.instance_type
  availability_zone = "sa-east-1a"
  tags = {
    Name = "Ubuntu_Free_Tier"
  }
}