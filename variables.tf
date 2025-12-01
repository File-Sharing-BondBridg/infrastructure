variable "project_id" {}
variable "region" {
  default = "europe-west4"
}

variable "k8s_host" {}
variable "k8s_token" {}
variable "k8s_ca" {}

variable "namespace" {
  default = "platform"
}

variable "environment" {}
