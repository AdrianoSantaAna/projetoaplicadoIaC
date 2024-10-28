locals {
  required_tags = {
    project     = var.project
    environment = var.environment
    Description = "Ana Exames - Agendamento"
    Owner       = "DevOps"
    Contact     = "aexamesti@anaexames.com.br"
    Terraform   = "true"
  }
  tags = merge(var.resource_tags, local.required_tags)
}

variable "project" {
  type = string
  default = "AnaExamesAgendamento"
}

variable "environment" {
  type = string
}

variable "account_id" {
  type = string
}


variable "region" {
  type = string
}

variable "cloudfront_url" {
  type = string
}

variable "resource_tags" {
  type    = map(any)
  default = {}
}

variable "waf_enabled" {
  type        = bool
  default     = false
}

variable "master_username" {
  type = string
}

variable "master_password" {
  type = string
}
