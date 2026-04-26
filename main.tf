resource "aws_vpc" "taskflow_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "taskflow-vpc"
  }
}

resource "aws_subnet" "taskflow_public_subnet_1" {
  vpc_id                  = aws_vpc.taskflow_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "taskflow-public-subnet-1"
  }
}

resource "aws_subnet" "taskflow_public_subnet_2" {
  vpc_id                  = aws_vpc.taskflow_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "taskflow-public-subnet-2"
  }
}

resource "aws_subnet" "taskflow_private_subnet_1" {
  vpc_id            = aws_vpc.taskflow_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "us-east-1a"
  tags = {
    Name = "taskflow-private-subnet-1"
  }
}

resource "aws_subnet" "taskflow_private_subnet_2" {
  vpc_id            = aws_vpc.taskflow_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "taskflow-private-subnet-2"
  }
}

resource "aws_internet_gateway" "taskflow_igw" {
  vpc_id = aws_vpc.taskflow_vpc.id
  tags = {
    Name = "taskflow-igw"
  }
}

resource "aws_eip" "taskflow_nat_eip" {
  tags = {
    Name = "taskflow-nat-eip"
  }
}

resource "aws_nat_gateway" "taskflow_nat_gateway" {
  allocation_id = aws_eip.taskflow_nat_eip.id
  subnet_id     = aws_subnet.taskflow_public_subnet_1.id
  tags = {
    Name = "taskflow-nat-gateway"
  }
}

resource "aws_route_table" "taskflow_public_route_table" {
  vpc_id = aws_vpc.taskflow_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.taskflow_igw.id
  }
  tags = {
    Name = "taskflow-public-route-table"
  }
}

resource "aws_route_table_association" "taskflow_public_subnet_1_association" {
  subnet_id      = aws_subnet.taskflow_public_subnet_1.id
  route_table_id = aws_route_table.taskflow_public_route_table.id
}

resource "aws_route_table_association" "taskflow_public_subnet_2_association" {
  subnet_id      = aws_subnet.taskflow_public_subnet_2.id
  route_table_id = aws_route_table.taskflow_public_route_table.id
}

resource "aws_route_table" "taskflow_private_route_table" {
  vpc_id = aws_vpc.taskflow_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.taskflow_nat_gateway.id
  }
  tags = {
    Name = "taskflow-private-route-table"
  }
}

resource "aws_route_table_association" "taskflow_private_subnet_1_association" {
  subnet_id      = aws_subnet.taskflow_private_subnet_1.id
  route_table_id = aws_route_table.taskflow_private_route_table.id
}

resource "aws_route_table_association" "taskflow_private_subnet_2_association" {
  subnet_id      = aws_subnet.taskflow_private_subnet_2.id
  route_table_id = aws_route_table.taskflow_private_route_table.id
}

resource "aws_ecr_repository" "taskflow_frontend_ecr" {
  name = "taskflow-frontend"
  tags = {
    Name = "taskflow-frontend"
  }
}

resource "aws_ecr_repository" "taskflow_backend_ecr" {
  name = "taskflow-backend"
  tags = {
    Name = "taskflow-backend"
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "taskflow_eks_cluster_role" {
  name = "taskflow-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "taskflow-eks-cluster-role"
  }
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "taskflow_eks_node_role" {
  name = "taskflow-eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "taskflow-eks-node-role"
  }
}

# Attach Policies to EKS Cluster Role
resource "aws_iam_role_policy_attachment" "taskflow_eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.taskflow_eks_cluster_role.name
}

# Attach Policies to EKS Node Role
resource "aws_iam_role_policy_attachment" "taskflow_eks_node_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.taskflow_eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "taskflow_eks_cni_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.taskflow_eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "taskflow_eks_ecr_readonly_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.taskflow_eks_node_role.name
}


resource "aws_eks_cluster" "taskflow_eks_cluster" {
  name     = "taskflow-eks-cluster"
  role_arn = aws_iam_role.taskflow_eks_cluster_role.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.taskflow_public_subnet_1.id,
      aws_subnet.taskflow_public_subnet_2.id,
      aws_subnet.taskflow_private_subnet_1.id,
      aws_subnet.taskflow_private_subnet_2.id,
    ]
  }

  tags = {
    Name = "taskflow-eks-cluster"
  }
}

resource "aws_eks_node_group" "taskflow_eks_node_group" {
  cluster_name    = aws_eks_cluster.taskflow_eks_cluster.name
  node_group_name = "taskflow-eks-node-group"
  node_role_arn   = aws_iam_role.taskflow_eks_node_role.arn
  subnet_ids = [
    aws_subnet.taskflow_private_subnet_1.id,
    aws_subnet.taskflow_private_subnet_2.id
  ]

  # Use Spot Instances for cost optimization
  capacity_type = "SPOT"

  # Instance type (you can modify the instance type if you prefer)
  instance_types = ["t3.medium", "t3a.medium", "m5.large"]

  # Desired instance count
  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  tags = {
    Name = "taskflow-eks-node-group"
  }
}