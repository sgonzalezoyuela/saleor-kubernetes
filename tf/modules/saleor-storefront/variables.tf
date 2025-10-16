variable "namespace" {
  description = "Kubernetes namespace for deployment"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enabled" {
  description = "Enable Saleor Storefront deployment"
  type        = bool
  default     = true
}

variable "image" {
  description = "Saleor Storefront Docker image"
  type        = string
  default     = "ghcr.io/saleor/storefront:latest"
}

variable "host" {
  description = "Saleor Storefront Docker image"
  type        = string
  default     = "ghcr.io/saleor/storefront:latest"
}

variable "saleor_api_url" {
  description = "Saleor API URL for storefront"
  type        = string
  default     = ""
}

variable "api_service_name" {
  description = "Name of the Saleor API service for internal connection"
  type        = string
  default     = "saleor-api"
}

variable "storefront_url" {
  description = "Public URL for the storefront"
  type        = string
  default     = ""
}

variable "app_token" {
  description = "Saleor app token for storefront"
  type        = string
  default     = ""
  sensitive   = true
}

variable "env_vars" {
  description = "Additional environment variables for storefront"
  type        = map(string)
  default     = {}
}

variable "memory_limit" {
  description = "Memory limit for storefront container"
  type        = string
  default     = "2Gi"
}

variable "cpu_limit" {
  description = "CPU limit for storefront container"
  type        = string
  default     = "2000m"
}

variable "memory_request" {
  description = "Memory request for storefront container"
  type        = string
  default     = "2Gi"
}

variable "cpu_request" {
  description = "CPU request for storefront container"
  type        = string
  default     = "2000m"
}

variable "ingress_enabled" {
  description = "Enable ingress for storefront"
  type        = bool
  default     = false
}
