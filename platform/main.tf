locals {
  namespace = var.namespace
}

variable "create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create the namespace if it doesn't exist"
}

resource "kubernetes_namespace" "platform" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = local.namespace
  }

  lifecycle {
    ignore_changes = [metadata[0].labels]  # Ignore label changes post-creation
  }
}

data "kubernetes_namespace" "platform" {
  count = var.create_namespace ? 0 : 1
  metadata {
    name = local.namespace
  }
}

output "platform_namespace" {
  value = local.namespace
}

resource "helm_release" "keycloak" {
  name             = "keycloak"
  repository       = "https://codecentric.github.io/helm-charts"
  chart            = "keycloak"
  version          = "18.10.0"
  namespace        = local.namespace
  create_namespace = false
  timeout          = 1200
  wait             = false
  values           = [file("${path.module}/helm_values/keycloak-values.yaml")]
  depends_on       = [kubernetes_namespace.platform, data.kubernetes_namespace.platform]
}

resource "helm_release" "minio" {
  name             = "minio"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "minio"
  version          = "12.8.5"
  namespace        = local.namespace

  values = [
    file("${path.module}/helm_values/minio-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.platform
  ]
}

resource "helm_release" "mongodb" {
  name             = "mongodb"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "mongodb"
  version          = "18.1.10"
  namespace        = local.namespace
  create_namespace = false
  values           = [file("${path.module}/helm_values/mongo-values.yaml")]
  depends_on       = [kubernetes_namespace.platform, data.kubernetes_namespace.platform]
}

resource "helm_release" "postgres" {
  name             = "postgres"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "postgresql"
  version          = "18.1.13"
  namespace        = local.namespace
  create_namespace = false
  timeout          = 600
  values           = [file("${path.module}/helm_values/postgres-values.yaml")]
  depends_on       = [kubernetes_namespace.platform, data.kubernetes_namespace.platform]
}

resource "helm_release" "nats" {
  name              = "nats"
  repository        = "https://nats-io.github.io/k8s/helm/charts/"
  chart             = "nats"
  version           = "2.12.2"
  namespace         = local.namespace
  create_namespace  = false
  timeout           = 600  # Give extra time for the recreate
  wait              = true  # Ensures pods are ready post-recreate
  values            = [file("${path.module}/helm_values/nats-values.yaml")]
  depends_on        = [kubernetes_namespace.platform, data.kubernetes_namespace.platform]
}

resource "kubernetes_secret" "datadog_secret" {
  metadata {
    name = "datadog-secret"
    namespace = local.namespace
  }

  data = {
    "api-key" = var.datadog_api_key
  }

  type = "Opaque"
}

resource "helm_release" "datadog" {
  name       = "datadog"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  namespace  = local.namespace

  values = [
    file("${path.module}/helm_values/datadog-values.yaml")
  ]

  depends_on = [
    kubernetes_secret.datadog_secret
  ]
}
