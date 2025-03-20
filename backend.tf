terraform {
  required_version = ">= 1.10.0"
  backend "s3" {
    encrypt      = true
    bucket       = ""
    region       = ""
    key          = ""
    use_lockfile = true
  }
}
