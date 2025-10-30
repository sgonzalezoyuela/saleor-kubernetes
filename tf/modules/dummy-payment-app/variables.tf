variable "namespace" {
  description = "Kubernetes namespace for deployment"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enabled" {
  description = "Enable deployment"
  type        = bool
  default     = true
}

variable "payment_app_image" {
  description = "Pre-built payment app Docker image with tag"
  type        = string
  default     = "ghcr.io/saleor/saleor-payment-app:latest"
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 3000
}

variable "svc_port" {
  description = "Service port"
  type        = number
  default     = 3000
}

variable "api_url" {
  description = "Saleor API URL for the app"
  type        = string
  default     = "http://saleor-api:8000/graphql/"
}

variable "public_access" {
  description = "Enable public LoadBalancer access"
  type        = bool
  default     = false
}

variable "saleor_api_url" {
  description = "Saleor API URL (computed from saleor-platform module)"
  type        = string
  default     = "http://saleor-api:8000"
}
