
# Fetch available zones for the specified region
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" { 
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "edc-vpc"
  }
}

locals {
  name = "edc-dev"
}

# Generate public subnets dynamically based on availability zones
resource "aws_subnet" "public_subnets" {
  for_each                = toset(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, index(data.aws_availability_zones.available.names, each.key))
  map_public_ip_on_launch = true
  tags = merge(
    {
      Name = "public-subnet-${each.key}"
    },
    {
      "kubernetes.io/role/elb" = "1"
    },
    {
      "karpenter.sh/discovery" = local.name
    }
  )
}

# Generate private subnets dynamically based on availability zones
resource "aws_subnet" "private_subnets" {
  for_each                = toset(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, length(data.aws_availability_zones.available.names) + index(data.aws_availability_zones.available.names, each.key))
  map_public_ip_on_launch = false
  tags = merge(
    {
      Name = "private-subnet-${each.key}"
    },
    {
      "kubernetes.io/role/internal-elb" = "1"
    },
    {
      "karpenter.sh/discovery" = local.name
    }
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "edc-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "edc-public-route-table"
  }
}

resource "aws_route_table_association" "public_route" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "edc-private-route-table"
  }
}

resource "aws_route_table_association" "private_route" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_security_group" "eks_node_group_sg" {
  name        = "eks-node-group-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "Security Group for EKS Node Group"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-group-sg"
    "karpenter.sh/discovery"   = local.name
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "Security Group for ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
    "karpenter.sh/discovery"   = local.name
  }
}
