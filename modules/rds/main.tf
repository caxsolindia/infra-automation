# modules/rds/main.tf

provider "aws" {
  region = var.region
}

# Reference VPC
data "aws_vpc" "custom_vpc" {
  id = var.vpc_id
}

# RDS Subnet Group
resource "aws_db_subnet_group" "example" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids
  tags = {
    Name = var.db_subnet_group_name
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = var.rds_security_group_name
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.ingress_cidr_blocks
  }

  tags = {
    Name = var.rds_security_group_name
  }
}

data "aws_availability_zones" "available" {}

# IAM Role for Enhanced Monitoring
resource "aws_iam_role" "enhanced_monitoring" {
  name = "rds-enhanced-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


# Attach policy to the role
resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  role       = aws_iam_role.enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Create a custom DB parameter group for query logging
resource "aws_db_parameter_group" "custom_pg_parameter_group" {
  name        = "custom-pg-parameter-group-13"
  family      = var.db_family 
  description = "Custom parameter group for PostgreSQL 13"

  parameter {
    name  = "log_statement"
    value = "all"  
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "0"    
  }

  tags = {
    Name = "custom-pg-parameter-group"
  }
}


# RDS instance
resource "aws_db_instance" "edc-db" {
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_name              = var.db_name
  identifier           = var.identifier
  username             = var.username
  password             = var.password
  parameter_group_name = aws_db_parameter_group.custom_pg_parameter_group.name
  db_subnet_group_name = aws_db_subnet_group.example.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible  = var.publicly_accessible
  multi_az             = var.multi_az
  availability_zone    = data.aws_availability_zones.available.names[0]
  skip_final_snapshot  = var.skip_final_snapshot
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  auto_minor_version_upgrade = true
  # timezone = var.timezone

  # Enable encryption at rest
  storage_encrypted = true

  # Enable enhanced monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = aws_iam_role.enhanced_monitoring.arn

  tags = {
    Name = var.db_instance_name
  }
}
