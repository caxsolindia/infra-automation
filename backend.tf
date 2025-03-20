terraform {
  required_version = ">= 1.10.0"
  backend "s3" {
    encrypt      = true
    bucket       = "edc-terraform-demo"
    region       = "ap-south-1"
    key          = "terraform.tfstate"
    use_lockfile = true
  }
}
