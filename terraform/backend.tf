terraform {
  backend "s3" {
    bucket         = "fider-terraform-state-275333454194"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    use_lockfile   = true
  }
}
