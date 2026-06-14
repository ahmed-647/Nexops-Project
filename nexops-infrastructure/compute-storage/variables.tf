
variable "aws_region" {
  type        = string
  description = "Target deployment region for cloud compute engines"
  default     = "ap-south-1"
}

variable "instance_type" {
  type        = string
  description = "The EC2 sizing tier for deploying NEXOPS cluster nodes"
  default     = "t3.small" # Economical and sufficient for control plane workloads
}