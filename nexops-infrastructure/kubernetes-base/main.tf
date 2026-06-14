
# 1. Fetch live production data links from the recently configured compute-storage layer
data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket = "nexops-tf-state-bucket-ahmed-647"
    key    = "compute/storage/terraform.tfstate"
    region = "ap-south-1"
  }
}

# 2. Automation Hook Executor for handling out-of-band application deployment
resource "null_resource" "k3s_bootstrap" {
  
  # Establishes an encrypted SSH tunnel securely into the active master node IP
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = data.terraform_remote_state.compute.outputs.ssh_private_key_pem
    host        = data.terraform_remote_state.compute.outputs.master_node_public_ip
    timeout     = "5m"
  }

  # Orchestrates remote terminal commands to patch OS, fetch binary utilities, and lock cluster core
  provisioner "remote-exec" {
    inline = [
      "echo '==> 🚀 Initializing NEXOPS Core Control Plane Platform Engine...'",
      "sudo apt-get update -y && sudo apt-get install -y curl",
      
      "echo '==> 📦 Rolling out highly optimized production grade K3s cluster execution runtime...'",
      "curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --disable traefik",
      
      "echo '==> 🔍 Checking container platform control status logs...'",
      "sudo systemctl enable k3s",
      "sudo systemctl start k3s",
      "kubectl get nodes",
      
      "echo '==> ✨ NEXOPS Orchestration Layer is now standing perfectly online!'"
    ]
  }
}