terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
provider "aws" {
  region = "ap-south-1"
  alias = "primary"
  profile = "default"
}
provider "aws" {
  region = "us-east-1"
  alias = "secondary"
  profile = "default"
}
