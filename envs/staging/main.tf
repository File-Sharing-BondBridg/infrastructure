terraform {
  required_version = ">= 1.5.0"
}

# ---------------- KIND CLUSTER ----------------
module "kind" {
  source          = "../../modules/kind-cluster"
  cluster_name    = "bondbridg"
  kubeconfig_path = "C:\\School\\File sharing\\K8s Config\\bondbridg-kubeconfig.yaml"
}

# ---------------- PROVIDERS ----------------
provider "kubernetes" {
  host                   = module.kind.host
  client_certificate     = base64decode(module.kind.client_certificate)
  client_key             = base64decode(module.kind.client_key)
  cluster_ca_certificate = base64decode(module.kind.ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = module.kind.host
    client_certificate     = base64decode(module.kind.client_certificate)
    client_key             = base64decode(module.kind.client_key)
    cluster_ca_certificate = base64decode(module.kind.ca_certificate)
  }
}

# ---------------- PLATFORM DEPLOYMENT ----------------
module "platform" {
  source      = "../../platform"
  namespace   = "file-sharing"
  environment = "staging"
  create_namespace = false
  datadog_api_key = var.datadog_api_key
}

variable "datadog_api_key" {
  description = "Datadog API key for platform monitoring"
  type        = string
  sensitive   = true
}