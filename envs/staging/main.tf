resource "null_resource" "kind_cluster" {
  provisioner "local-exec" {
    command = <<EOT
      kind create cluster --name bondbridg-staging --config ${path.module}/kind-config.yaml || true
      # configure kubectl context if needed
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}
