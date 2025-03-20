variable "vpcid" {}
variable "region" {}


variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "The API server endpoint URL for the EKS cluster"
  type        = string
}

variable "cluster_token" {
  description = "The authentication token for the EKS cluster"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "The certificate authority data for the EKS cluster"
  type        = string
}

variable "oidc" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "alb_security_group_ids" {
  type = string
}

variable "service_account_name" {
  default = "alb-ingress-controller"
}

variable "eks_cluster_endpoint" {}
variable "eks_cluster_certificate" {}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}
