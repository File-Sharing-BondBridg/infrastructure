module "gke" {
  source     = "../../modules/gke-cluster"
  project_id = var.project_id
  region     = var.region
}

module "platform" {
  source     = "../../platform"
  namespace  = "platform"
  environment = "production"

  k8s_host = module.gke.host
  k8s_ca   = module.gke.ca_certificate
  k8s_token = module.gke.token
}