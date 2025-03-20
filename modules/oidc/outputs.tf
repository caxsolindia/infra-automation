output "eks_cluster_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc_provider.arn
}
