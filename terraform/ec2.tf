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
resource "aws_instance" "app_server" {
  ami           = "ami-0c5410a9e09852edd"
  instance_type = "t2.micro"

  tags = {
    Name = "ProjetoAplicado_testeTF"
  }
}
