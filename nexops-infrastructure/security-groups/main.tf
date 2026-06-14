
# 1. Fetch Remote State Data from the VPC Network Module to link resources dynamically
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "nexops-tf-state-bucket-ahmed-647"
    key    = "network/vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}

# 2. Public Edge/ALB Security Group (Handles external traffic and management sessions)
resource "aws_security_group" "public_edge" {
  name        = "nexops-public-edge-sg"
  description = "Allows ingress public web traffic and automated provisioning access"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Inbound SSH Access (Required for automated remote-exec orchestration hooks)
  ingress {
    description = "Allows automated remote-exec provisioning loops over terminal shells"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP Access
  ingress {
    description = "Allow global public HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTPS Access
  ingress {
    description = "Allow global public HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rule (Allows full outbound routing to internal networks)
  egress {
    description = "Allow all outbound traffic securely"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "nexops-public-edge-sg"
    Layer       = "Edge"
    Environment = "production"
  }
}

# 3. Private Compute Security Group (Highly protected node layer for K3s/EKS)
resource "aws_security_group" "private_compute" {
  name        = "nexops-private-compute-sg"
  description = "Isolates backend compute workloads from direct public entry points"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Restrict internal application routing (Traffic must pass through Public Edge SG first)
  ingress {
    description     = "Allow reverse proxy traffic strictly via public edge firewall"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.public_edge.id]
  }

  # Inter-Node Communication rule (Nodes within this group can seamlessly speak to each other)
  ingress {
    description = "Allow secure full internal loop communication between backend layers"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Outbound Route via NAT Gateway for updates
  egress {
    description = "Allow restricted external path updates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "nexops-private-compute-sg"
    Layer       = "Compute"
    Environment = "production"
  }
}