terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "sa-east-1"  
}

# Criação de um bucket S3 
resource "aws_s3_bucket" "meu_bucket" {
  bucket = "projetoaplicadoxpeanaexamestest"  
  tags = {
    Name        = "Bucket AnaExames"
    Environment = "Production"
  }
}
