
output "public_edge_sg_id" {
  description = "The ID of the external edge security group"
  value       = aws_security_group.public_edge.id
}

output "private_compute_sg_id" {
  description = "The ID of the internal isolated compute security group"
  value       = aws_security_group.private_compute.id
}