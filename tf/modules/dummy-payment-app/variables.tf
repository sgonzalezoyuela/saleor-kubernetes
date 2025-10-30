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

variable "app_image" {
  description = "Docker image (e.g., node:20-alpine)"
  type        = string
  default     = "node:20-alpine"
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

variable "git_ref" {
  description = "Git commit, branch, or tag to checkout (e.g., main, v1.0.0, commit-hash)"
  type        = string
  default     = "main"
}

variable "use_prebuilt_image" {
  description = "Use pre-built Docker image instead of building from source"
  type        = bool
  default     = true
}

variable "prebuilt_image" {
  description = "Pre-built payment app Docker image"
  type        = string
  default     = "ghcr.io/saleor/saleor-kubernetes/payment-app:latest"
}
