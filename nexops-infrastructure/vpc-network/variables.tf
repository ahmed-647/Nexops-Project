
variable "aws_region" {
  type        = string
  description = "The target AWS region for all network resources"
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  type        = string
  description = "The primary CIDR block allocation for the NEXOPS production VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR allocations for public-facing subnets (ALB, NAT Gateways)"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR allocations for isolated internal subnets (K3s/EKS Nodes, DBs)"
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "Target multi-AZ configuration for High Availability (HA)"
  default     = ["ap-south-1a", "ap-south-1b"]
}