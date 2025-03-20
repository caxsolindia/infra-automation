
data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}


data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# Fetch the existing IAM user
data "aws_iam_user" "existing_rbac_user" {
  user_name = var.iam_user_name 
}

resource "aws_iam_user_policy" "rbac_user_policy" {
  name   = "rbac-user-policy"
  user   = data.aws_iam_user.existing_rbac_user.user_name  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "*"
      }
    ]
  })
}

# develop namespace full access for rbac-user

resource "kubernetes_namespace" "ns" {
  metadata {
    name = "develop"  # Specify your desired namespace name
  }
}

resource "kubernetes_role" "develop_namespace_admin" {
  metadata {
    name      = "develop-namespace-admin"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "bind_develop_access" {
  metadata {
    name      = "bind-develop-access"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "develop-access"
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.develop_namespace_admin.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "aws_iam_role" "rbac_user_role" {
  name = "rbac-user-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.iam_user_name}"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_eks_access_entry" "rbac_user_access" {
  cluster_name      = var.cluster_name
  principal_arn     = aws_iam_role.rbac_user_role.arn
  kubernetes_groups = ["develop-access"]  
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "rbac_user_policy" {
  cluster_name  = var.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  principal_arn = aws_iam_role.rbac_user_role.arn

  access_scope {
    type       = "namespace"
    namespaces = ["develop"]
  }
}


