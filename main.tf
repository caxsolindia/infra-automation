module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "eks" {
  source                 = "./modules/eks"
  subnet_ids             = var.use_private_subnets ? module.vpc.private_subnet_ids : module.vpc.public_subnet_ids
  sg                     = module.vpc.eks_node_group_security_group_id
  instance_types         = var.instance_types
  eks_kubernetes_version = var.eks_kubernetes_version
  region                 = var.region
  cluster_name           = var.cluster_name
}

# module "rbac" {
#   source                 = "./modules/rbac"
#   cluster_endpoint       = module.eks.eks_cluster_endpoint
#   cluster_token          = module.eks.eks_token_command
#   cluster_ca_certificate = module.eks.eks_cluster_certificate_authority
#   cluster_name           = module.eks.eks_cluster_name
#   iam_user_name          = var.iam_user_name
# }

module "oidc" {
  source      = "./modules/oidc"
  oidc_issuer = module.eks.oidc_provider_url
  thumbprint  = module.eks.eks_cluster_certificate_authority
  depends_on  = [module.eks]
}

module "add-on" {
  source                 = "./modules/add-on"
  cluster_endpoint       = module.eks.eks_cluster_endpoint
  cluster_token          = module.eks.eks_token_command
  cluster_ca_certificate = module.eks.eks_cluster_certificate_authority
  cluster_name           = module.eks.eks_cluster_name
  depends_on             = [module.eks]
}

module "alb-ingress" {
  source                  = "./modules/alb-ingress"
  vpcid                   = module.vpc.vpcid
  subnet_ids              = module.vpc.public_subnet_ids
  alb_security_group_ids  = module.vpc.alb_security_group_id
  region                  = var.region
  cluster_endpoint        = module.eks.eks_cluster_endpoint
  cluster_token           = module.eks.eks_token_command
  cluster_ca_certificate  = module.eks.eks_cluster_certificate_authority
  cluster_name            = module.eks.eks_cluster_name
  oidc                    = module.eks.oidc_provider_url
  eks_cluster_endpoint    = module.eks.eks_cluster_endpoint
  eks_cluster_certificate = module.eks.eks_cluster_certificate_authority
}


module "rds" {
  source                              = "./modules/rds"
  region                              = var.region
  vpc_id                              = module.vpc.vpcid
  subnet_ids                          = var.use_private_subnets ? module.vpc.private_subnet_ids : module.vpc.public_subnet_ids
  db_subnet_group_name                = var.db_subnet_group_name
  rds_security_group_name             = var.rds_security_group_name
  ingress_cidr_blocks                 = var.ingress_cidr_blocks
  allocated_storage                   = var.allocated_storage
  engine                              = var.engine
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class
  db_name                             = var.db_name
  username                            = var.username
  password                            = var.password
  parameter_group_name                = var.parameter_group_name
  publicly_accessible                 = var.publicly_accessible
  multi_az                            = var.multi_az
  skip_final_snapshot                 = var.skip_final_snapshot
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  db_instance_name                    = var.db_instance_name
  timezone                            = var.timezone
  storage_type                        = var.storage_type
  identifier                          = var.identifier
  db_port                             = var.db_port
  monitoring_interval                 = var.monitoring_interval
  db_family                           = var.db_family
}

