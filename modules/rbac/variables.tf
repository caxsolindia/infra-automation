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

variable "iam_user_name" {
  description = "The name of the IAM user"
  type        = string
}