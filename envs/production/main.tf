# providers.tf (envs/production/providers.tf)
terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = { source = "hashicorp/kubernetes" }
    helm = { source = "hashicorp/helm" }
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}

# modules/gke-cluster/main.tf (imported module shown inline here)
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.gcp_zone

  # Basic control plane config (zonal cluster is cheaper than regional)
  remove_default_node_pool = true
  initial_node_count       = 1

  # Enable HTTP load balancing if you want LB
  addons_config {
    http_load_balancing {}
  }

  # Autopilot? we use Standard to allow preemptible nodes
  ip_allocation_policy {}
}

resource "google_container_node_pool" "default_pool" {
  name       = "small-pool"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location

  node_config {
    machine_type = var.node_machine_type
    preemptible  = var.preemptible_nodes
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  autoscaling {
    min_node_count = var.node_min_count
    max_node_count = var.node_max_count
  }
}
