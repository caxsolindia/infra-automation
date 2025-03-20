variable "subnet_ids" {
  description = "List of public subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "instance_types" {
  
}

variable "eks_kubernetes_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  
}


variable "region" {
  description = "region name"
  type        = string
}

variable "cluster_name" {
   type        = string
}

variable "sg" {}