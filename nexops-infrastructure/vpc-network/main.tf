
# 1. Main Isolated Network Boundary
resource "aws_vpc" "nexops_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "nexops-enterprise-vpc"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}

# 2. Public Subnets Layout (For Edge Routing & Public Load Balancers)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.nexops_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                               = "nexops-public-subnet-${var.availability_zones[count.index]}"
    "kubernetes.io/role/elb"           = "1" # Required tag for AWS Load Balancer Controller automation
    Environment                        = "production"
  }
}

# 3. Private Subnets Layout (For Secure Internal Cluster Compute Nodes)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.nexops_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                               = "nexops-private-subnet-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb"  = "1" # Required tag for internal microservices K8s routing
    Environment                        = "production"
  }
}

# 4. Internet Gateway (North-South Edge Traffic Controller)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.nexops_vpc.id

  tags = {
    Name        = "nexops-internet-gateway"
    Environment = "production"
  }
}

# 5. Static Elastic IP (EIP) Allocation for the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name        = "nexops-nat-eip"
    Environment = "production"
  }
}

# 6. Highly Available NAT Gateway (Secures private node outbound update patches)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id # Placed strategically inside the first public subnet

  tags = {
    Name        = "nexops-nat-gateway"
    Environment = "production"
  }
}

# 7. Route Tables Generation
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.nexops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "nexops-public-route-table"
    Environment = "production"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.nexops_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name        = "nexops-private-route-table"
    Environment = "production"
  }
}

# 8. Subnet to Route Table Strategic Associations
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}