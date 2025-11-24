provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path  # from gke outputs or local ~/.kube/config
  }
}

resource "helm_release" "postgres_fileservice" {
  name       = "postgres-fileservice"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = "file-service"
  create_namespace = true

  values = [
    file("${path.module}/helm_values/postgres-values.yaml")
  ]
}
