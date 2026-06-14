
output "master_node_public_ip" {
  description = "The public entrypoint IP of the master host machine"
  value       = aws_instance.nexops_master_node.public_ip
}

output "ssh_connection_string" {
  description = "Direct terminal connection command string to jump onto the host machine"
  value       = "ssh -i nexops-mumbai-ssh-key.pem ubuntu@${aws_instance.nexops_master_node.public_ip}"
}

# Extra attribute addition inside compute-storage/outputs.tf
output "ssh_private_key_pem" {
  description = "Cryptographic access private token exposed securely for pipeline execution"
  value       = tls_private_key.nexops_ssh_key.private_key_pem
  sensitive   = true # Marks output hidden inside basic prints to secure identity leaks
}