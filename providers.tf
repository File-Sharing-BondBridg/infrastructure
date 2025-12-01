terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.13"
    }
  }

  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  host                   = var.k8s_host
  token                  = var.k8s_token
  cluster_ca_certificate = base64decode(var.k8s_ca)
}

provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    token                  = var.k8s_token
    cluster_ca_certificate = base64decode(var.k8s_ca)
  }
}
