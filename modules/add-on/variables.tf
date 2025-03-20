
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

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
  description = "List of EKS addons to install with their names and versions."
  default = [
    {
      name    = "vpc-cni"
      version = "v1.19.3-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.11.4-eksbuild.2"
    },
    {
      name    = "kube-proxy"
      version = "v1.32.0-eksbuild.2"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.39.0-eksbuild.1" 
    },
    {
      name    = "aws-efs-csi-driver"
      version = "v2.1.6-eksbuild.1" 
    },
    {
      name    = "eks-pod-identity-agent"
      version = "v1.3.5-eksbuild.2"  
    }
  ]
}