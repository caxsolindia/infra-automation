vpc_cidr = "10.0.0.0/16"
region   = ""

db_subnet_group_name                = ""
rds_security_group_name             = ""
ingress_cidr_blocks                 = ["0.0.0.0/0"]
allocated_storage                   = 
engine                              = ""
engine_version                      = ""
instance_class                      = ""
db_name                             = ""
username                            = ""
password                            = ""
parameter_group_name                = ""
publicly_accessible                 = true
multi_az                            = false
skip_final_snapshot                 = true
iam_database_authentication_enabled = true
db_instance_name                    = ""
identifier                          = ""
db_port                             = "5432"
monitoring_interval                 = "60"
db_family                           = ""


instance_types         = ["t3.medium"]
eks_kubernetes_version = "1.32"
cluster_name           = ""
timezone               = ""
storage_type           = "gp3"
