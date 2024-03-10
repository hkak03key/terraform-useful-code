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
  region = "ap-northeast-1"
}
