data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

resource "aws_iam_policy" "alb_ingress_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for the ALB Ingress Controller"
  policy      = file("modules/alb-ingress/alb-ingress-policy.json")
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_role" "alb_ingress_role" {
  name = "eks-alb-ingress-controller-role"

  lifecycle {
    create_before_destroy = true
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.oidc, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc, "https://", "")}:sub" = "system:serviceaccount:kube-system:${var.service_account_name}"
          }
        }
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "alb_ingress_policy_attachment" {
  role       = aws_iam_role.alb_ingress_role.name
  policy_arn = aws_iam_policy.alb_ingress_controller.arn
}

resource "kubernetes_service_account" "alb_ingress_sa" {
  metadata {
    name      = "alb-ingress-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_ingress_role.arn
    }
  }
  depends_on = [var.cluster_name]
}

provider "helm" {
  alias = "alb"
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "null_resource" "connect_to_eks" {
  depends_on = [data.aws_eks_cluster_auth.cluster]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}"
  }
}


resource "helm_release" "alb_ingress_controller" {
  provider   = helm.alb
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  values = [
    <<EOF
    clusterName: "${var.cluster_name}"
    region: "${var.region}"
    vpcId: "${var.vpcid}"
    subnetIds:
       - ${join(",", var.subnet_ids)}
    securityGroup:
       id: "${var.alb_security_group_ids}"
    replicaCount: 2
    serviceAccount:
      create: false
      name: "alb-ingress-controller"
    EOF
  ]

  depends_on = [null_resource.connect_to_eks]
}

# resource "helm_release" "metrics_server" {
#   name       = "metrics-server"
#   repository = "https://kubernetes-sigs.github.io/metrics-server/"
#   chart      = "metrics-server"
#   namespace  = "kube-system"

#   depends_on = [null_resource.connect_to_eks]
# }

# Service account for connect cluster inside script level

resource "aws_iam_role" "eks_sa_role" {
  name = "eks-service-account-role"

  lifecycle {
    create_before_destroy = true
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.oidc, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc, "https://", "")}:sub" = "system:serviceaccount:default:eks-sa"
          }
        }
      }
    ]
  })

}


resource "aws_iam_policy" "eks_policy" {
  name        = "eks_policy"
  path        = "/"
  description = "IAM policy for EKS cluster access with additional permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = "arn:aws:eks:${var.region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZones",
          "route53:GetChange"
        ]
        Resource = "arn:aws:route53:::hostedzone/Z059167725UOMPV5GV3I1"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::edcaas-certificate-data",
          "arn:aws:s3:::edcaas-certificate-data/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "eks-attach" {
  role       = aws_iam_role.eks_sa_role.name
  policy_arn = aws_iam_policy.eks_policy.arn
}

resource "aws_eks_access_entry" "eks_admin_access" {
  cluster_name     = var.cluster_name
  principal_arn    = aws_iam_role.eks_sa_role.arn
  type             = "STANDARD"
  kubernetes_groups = ["eks-admins"]
  
  depends_on = [aws_iam_role.eks_sa_role]
}

# resource "aws_eks_access_policy_association" "eks_admin_cluster" {
#   cluster_name  = var.cluster_name
#   principal_arn = aws_eks_access_entry.eks_admin_access.principal_arn
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

#   access_scope {
#     type = "cluster"
#   }
# }

resource "kubernetes_cluster_role_binding" "eks_admins_binding" {
  metadata {
    name = "eks-admins-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "Group"
    name      = "eks-admins"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_service_account" "eks_sa" {
  metadata {
    name      = "eks-sa"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_sa_role.arn
    }
  }
}

# # karpenter

# terraform {
#   required_providers {
#     kubectl = {
#       source  = "alekc/kubectl"
#       version = ">= 2.0.0"
#     }
#   }
# }

# provider "aws" {
#   region = var.region
# }

# provider "aws" {
#   region = var.aws_region
#   alias  = "virginia"
# }

# provider "helm" {
#   kubernetes {
#     host                   = var.eks_cluster_endpoint
#     cluster_ca_certificate = base64decode(var.eks_cluster_certificate)

#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       args = ["eks", "get-token", "--cluster-name", var.cluster_name]
#     }
#   }
# }

# provider "kubectl" {
#   apply_retry_count      = 5
#   host                   = var.eks_cluster_endpoint
#   cluster_ca_certificate = base64decode(var.eks_cluster_certificate)
#   load_config_file       = false

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args = ["eks", "get-token", "--cluster-name", var.cluster_name]
#   }
# }

# data "aws_ecrpublic_authorization_token" "token" {
#   provider = aws.virginia
# }

# module "karpenter" {
#   source = "terraform-aws-modules/eks/aws//modules/karpenter"

#   cluster_name = var.cluster_name

#   enable_v1_permissions = true

#   enable_pod_identity             = true
#   create_pod_identity_association = true

#   # IAM policies to the Karpenter node IAM role
#   node_iam_role_additional_policies = {
#     AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   }
# }



# resource "null_resource" "wait_for_alb" {
#   provisioner "local-exec" {
#     command = "sleep 60" 
#   }
#   depends_on = [helm_release.alb_ingress_controller]
# }


# resource "helm_release" "karpenter" {
#   namespace           = "kube-system"
#   name                = "karpenter"
#   repository          = "oci://public.ecr.aws/karpenter"
#   repository_username = data.aws_ecrpublic_authorization_token.token.user_name
#   repository_password = data.aws_ecrpublic_authorization_token.token.password
#   chart               = "karpenter"
#   version             = "1.0.0"
#   wait                = false

#   values = [
#     <<-EOT
#     serviceAccount:
#       name: ${module.karpenter.service_account}
#     settings:
#       clusterName: ${var.cluster_name}
#       clusterEndpoint: ${var.cluster_endpoint}
#       interruptionQueue: ${module.karpenter.queue_name}
#     EOT
#   ]
#   depends_on = [null_resource.wait_for_alb]
# }

# resource "kubectl_manifest" "karpenter_node_pool" {
#   yaml_body = <<-YAML
#     apiVersion: karpenter.sh/v1beta1
#     kind: NodePool
#     metadata:
#       name: default
#     spec:
#       template:
#         spec:
#           nodeClassRef:
#             name: default
#           requirements:
#             - key: "karpenter.k8s.aws/instance-category"
#               operator: In
#               values: ["t"]
#             - key: "karpenter.k8s.aws/instance-cpu"
#               operator: In
#               values: ["4", "8", "16", "32"]
#             - key: "karpenter.k8s.aws/instance-hypervisor"
#               operator: In
#               values: ["nitro"]
#             - key: "karpenter.k8s.aws/instance-generation"
#               operator: Gt
#               values: ["2"]
#       limits:
#         cpu: 1000
#       disruption:
#         consolidationPolicy: WhenEmpty
#         consolidateAfter: 30s
#       ttlSecondsAfterEmpty: 60
#   YAML

#   depends_on = [
#     kubectl_manifest.karpenter_node_class
#   ]
# }

# resource "kubectl_manifest" "karpenter_node_class" {
#   yaml_body = <<-YAML
#     apiVersion: karpenter.k8s.aws/v1beta1
#     kind: EC2NodeClass
#     metadata:
#       name: default
#     spec:
#       amiFamily: AL2023
#       role: ${module.karpenter.node_iam_role_name}
#       subnetSelectorTerms:
#         - tags:
#             karpenter.sh/discovery: ${var.cluster_name}
#       securityGroupSelectorTerms:
#         - tags:
#             karpenter.sh/discovery: ${var.cluster_name}
#       tags:
#         karpenter.sh/discovery: ${var.cluster_name}
#   YAML

#   depends_on = [
#     helm_release.karpenter
#   ]
# }
