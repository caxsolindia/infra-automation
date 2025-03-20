vpc_cidr = "10.0.0.0/16"
region   = "eu-central-1"

db_subnet_group_name                = "edc-db-subnet-group"
rds_security_group_name             = "rds-security-group"
ingress_cidr_blocks                 = ["0.0.0.0/0"]
allocated_storage                   = 100
engine                              = "postgres"
engine_version                      = "13.20"
instance_class                      = "db.t4g.small"
db_name                             = "edc"
username                            = "postgres"
password                            = "q^RaKpdLhCVgf&Ts$S&V&5"
parameter_group_name                = "aws_db_parameter_group.custom_pg_parameter_group.name"
publicly_accessible                 = true
multi_az                            = false
skip_final_snapshot                 = true
iam_database_authentication_enabled = true
db_instance_name                    = "edc"
identifier                          = "edc-rds"
db_port                             = "5432"
monitoring_interval                 = "60"
db_family                           = "postgres13"


instance_types         = ["t3.medium"]
eks_kubernetes_version = "1.32"
cluster_name           = "edc-dev"
timezone               = "Central European Time"
storage_type           = "gp3"
#iam_user_name          = "edc-user"