terraform {
  backend "s3" {
    bucket         = "fider-terraform-state-181907717176"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
  }
}