
# 1. Remote Data State Fetchers to maintain infrastructure decoupling
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "nexops-tf-state-bucket-ahmed-647"
    key    = "network/vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}

data "terraform_remote_state" "security_groups" {
  backend = "s3"
  config = {
    bucket = "nexops-tf-state-bucket-ahmed-647"
    key    = "security/groups/terraform.tfstate"
    region = "ap-south-1"
  }
}

# 2. Automated AMI Query Engine for fetching the latest official Ubuntu 24.04 Image
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical official owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 3. Cryptographic Key Management for secure SSH terminal handshakes
resource "tls_private_key" "nexops_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployed_key" {
  key_name   = "nexops-mumbai-ssh-key"
  public_key = tls_private_key.nexops_ssh_key.public_key_openssh
}

# Save the private key locally inside root environment to download for terminal SSH
resource "local_file" "save_private_key" {
  content         = tls_private_key.nexops_ssh_key.private_key_pem
  filename        = "${path.module}/nexops-mumbai-ssh-key.pem"
  file_permission = "0600" # Strict read-only permissions required by SSH protocols
}

# 4. Master Compute Cluster Host Machine Deployment
resource "aws_instance" "nexops_master_node" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployed_key.key_name

  # Placed inside the secure, scalable public subnet zone mapped by remote state data
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  vpc_security_group_ids = [data.terraform_remote_state.security_groups.outputs.public_edge_sg_id]

  # Root Block Storage allocation customized for handling dense application image pull states
  root_block_device {
    volume_size           = 30 # 30 GB high-speed standard allocation
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = "nexops-master-control-node"
    Role        = "Kubernetes-Control-Plane"
    Environment = "production"
  }
}