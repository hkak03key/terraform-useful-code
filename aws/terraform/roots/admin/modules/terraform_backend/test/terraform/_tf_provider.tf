terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
  required_version = "1.7.4"
}


provider "aws" {

  default_tags {
    tags = {
      env               = var.env
      github_repository = "https://github.com/hkak03key/terraform-useful-code"
    }
  }
}
