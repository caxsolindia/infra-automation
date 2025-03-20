
variable "region" {
  description = "The AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "Name for the DB Subnet Group"
  type        = string
}

variable "rds_security_group_name" {
  description = "Name for the RDS Security Group"
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed for inbound access to the RDS instance"
  type        = list(string)
}

variable "allocated_storage" {
  description = "Allocated storage for the RDS instance"
  type        = number
}

variable "engine" {
  description = "The RDS engine to use"
  type        = string
}

variable "engine_version" {
  description = "The engine version for the RDS instance"
  type        = string
}

variable "instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "username" {
  description = "Master username for the RDS instance"
  type        = string
}

variable "password" {
  description = "Master password for the RDS instance"
  type        = string
}

variable "parameter_group_name" {
  description = "Parameter group for the RDS instance"
  type        = string
}

variable "publicly_accessible" {
  description = "Whether the RDS instance should be publicly accessible"
  type        = bool
}

variable "multi_az" {
  description = "Whether to create a multi-availability zone RDS instance"
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when deleting the RDS instance"
  type        = bool
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM authentication for RDS"
  type        = bool
}

variable "db_instance_name" {
  description = "The name of the RDS instance"
  type        = string
}

variable "timezone" {
  description = "Timezone for the RDS instance"
  type        = string
}

variable "storage_type" {
  description = "The storage type to be associated with the DB instance."
  type        = string
}

variable "identifier" {
  description = "The name of rds resource name"
  type        = string
}

variable "db_port" {
  description = "Port number for database access"
  type        = number
}



variable "monitoring_interval" {
  description = "Interval in seconds for enhanced monitoring"
  type        = number
}


variable "db_family" {
  description = "The family of the database parameter group"
  type        = string
}
