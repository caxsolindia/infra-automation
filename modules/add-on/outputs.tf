
output "eks_addons" {
  description = "The list of EKS add-ons installed"
  value       = aws_eks_addon.addons
}