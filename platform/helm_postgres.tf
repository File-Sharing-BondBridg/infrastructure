resource "helm_release" "postgres_fileservice" {
  name       = "postgres-fileservice"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = local.namespace
  create_namespace = true

  values = [
    file("${path.module}/helm_values/postgres-values.yaml")
  ]
}
