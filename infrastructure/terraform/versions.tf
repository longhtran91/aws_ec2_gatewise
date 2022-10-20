terraform {
  required_version = ">= 1.3"
  cloud {
    organization = "lhtran"

    workspaces {
      name = "aws_ec2_gatewise"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.3"
    }
  }
}



