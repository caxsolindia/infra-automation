terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}

provider "tls" {}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner   = "MHP"
      Project = "EDCAAS-POC"
      env     = "development"
    }
  }
}