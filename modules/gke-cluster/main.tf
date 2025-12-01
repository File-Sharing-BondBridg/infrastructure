resource "google_container_cluster" "primary" {
  name     = "bondbridg-gke"
  location = var.region
  project  = var.project_id

  remove_default_node_pool = true
  initial_node_count       = 1

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {}
}

resource "google_container_node_pool" "default" {
  name       = "default-pool"
  cluster    = google_container_cluster.primary.id
  location   = var.region
  project    = var.project_id

  node_count = 1

  node_config {
    machine_type = "e2-small"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

output "host" {
  value = google_container_cluster.primary.endpoint
}

output "ca_certificate" {
  value = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}

output "token" {
  value = data.google_client_config.default.access_token
}

data "google_client_config" "default" {}
