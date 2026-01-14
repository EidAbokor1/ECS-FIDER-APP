terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      project = "ecs-fider"
      managedby = "tf"
      enviroment = "production"
    }
  }
}
