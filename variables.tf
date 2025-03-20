
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}
variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}
variable "rds_security_group_name" {
  description = "Name of the RDS security group"
  type        = string
}
variable "ingress_cidr_blocks" {
  description = "List of CIDR blocks for ingress traffic"
  type        = list(string)
}
variable "allocated_storage" {
  description = "The allocated storage size for the database (in gigabytes)"
  type        = number
}
variable "engine" {
  description = "The database engine to be used for the RDS instance (e.g., mysql, postgres)"
  type        = string
}
variable "engine_version" {
  description = "The version of the database engine to be used for the RDS instance"
  type        = string
}
variable "instance_class" {
  description = "The instance class for the RDS instance (e.g., db.t3.micro, db.m5.large)"
  type        = string
}
variable "db_name" {
  description = "The name of the database for the RDS instance"
  type        = string
}
variable "username" {
  description = "The master username for the RDS instance"
  type        = string
}
variable "password" {
  description = "The master password for the RDS instance"
  type        = string
  sensitive   = true
}
variable "parameter_group_name" {
  description = "The name of the DB parameter group"
  type        = string
}
variable "publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  type        = bool
}
variable "multi_az" {
  description = "Whether to enable Multi-AZ deployment for the RDS instance"
  type        = bool
}
variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot before deletion of the RDS instance"
  type        = bool
}
variable "iam_database_authentication_enabled" {
  description = "Whether to enable IAM database authentication"
  type        = bool
}
variable "db_instance_name" {
  description = "The name of the DB instance"
  type        = string
}
variable "instance_types" {
  description = "A list of instance types for RDS instances"
  type        = list(string)
}
variable "eks_kubernetes_version" {
  description = "The version of Kubernetes for the EKS cluster"
  type        = string
}
variable "timezone" {
  description = "The timezone for the system"
  type        = string
}
variable "storage_type" {
  description = "The storage type for the RDS instance"
  type        = string
}
variable "identifier" {
  description = "An identifier for the resource"
  type        = string
}
variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
}
# variable "iam_user_name" {
#   description = "The IAM username"
#   type        = string
# }
variable "db_port" {
  description = "The port on which the DB instance listens"
  type        = number
}

variable "use_private_subnets" {
  type    = bool
  default = false
}


variable "monitoring_interval" {
  description = "The interval for monitoring the RDS instance"
  type        = number
}

variable "db_family" {
  description = "The family of the database parameter group"
  type        = string
}
