
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
          Federated = ""
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
    replicaCount: 2
    serviceAccount:
      create: false
      name: "alb-ingress-controller"
    EOF
  ]

  depends_on = [null_resource.connect_to_eks]
}


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
          Federated = ""
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

