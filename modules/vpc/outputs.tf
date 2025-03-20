
output "eks_node_group_security_group_id" {
  description = "Security Group ID for EKS Node Group"
  value       = aws_security_group.eks_node_group_sg.id # Ensure this resource exists in the vpc module
}

output "alb_security_group_id" {
  description = "Security Group ID for ALB"
  value       = aws_security_group.alb_sg.id # Ensure this resource exists in the vpc module
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = [for subnet in aws_subnet.public_subnets : subnet.id]
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = [for subnet in aws_subnet.private_subnets : subnet.id]
}

output "vpcid" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}
