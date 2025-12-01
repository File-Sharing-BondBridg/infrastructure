variable "namespace" {
  type        = string
  description = "Namespace where platform components are deployed"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev/staging/prod)"
  default     = "dev"
}
