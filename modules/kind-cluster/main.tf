variable "cluster_name" {
  type = string
  description = "Name of the Kind cluster"
}

variable "kubeconfig_path" {
  type = string
  description = "Full path to read kubeconfig file (must exist)"
}

# Verify existing cluster (optional but recommended for "keep in check")
resource "null_resource" "verify_cluster" {
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command = <<EOT
$clusterName = "${var.cluster_name}"
$clusters = & kind get clusters
if ($clusters -notmatch [regex]::Escape($clusterName)) {
    Write-Error "Cluster '$clusterName' does not exist. Run 'kind create cluster --name $clusterName' manually first."
    exit 1
}
Write-Output "Cluster '$clusterName' verified."
EOT
  }
}

# Export kubeconfig if not present (one-time helper; idempotent)
resource "null_resource" "export_kubeconfig" {
  triggers = {
    cluster_name    = var.cluster_name
    kubeconfig_path = var.kubeconfig_path
  }

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command = <<EOT
$kubeconfigPath = "${var.kubeconfig_path}"
$clusterName = "${var.cluster_name}"
if (-not (Test-Path $kubeconfigPath)) {
    Write-Output "Kubeconfig not found at $kubeconfigPath; exporting from existing cluster."
    & kind export kubeconfig --name $clusterName | Out-File -FilePath $kubeconfigPath -Encoding utf8
} else {
    Write-Output "Kubeconfig already exists at $kubeconfigPath."
}
EOT
  }

  depends_on = [null_resource.verify_cluster]
}

# Read the kubeconfig
data "local_file" "kubeconfig" {
  filename = var.kubeconfig_path

  depends_on = [null_resource.export_kubeconfig]
}

locals {
  kubeconfig = yamldecode(data.local_file.kubeconfig.content)
}

# Extract provider-compatible values
output "host" {
  value = local.kubeconfig.clusters[0].cluster.server
}

output "ca_certificate" {
  value = local.kubeconfig.clusters[0].cluster["certificate-authority-data"]
}

output "client_certificate" {
  value = local.kubeconfig.users[0].user["client-certificate-data"]
}

output "client_key" {
  value = local.kubeconfig.users[0].user["client-key-data"]
}