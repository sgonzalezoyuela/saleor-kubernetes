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
  default     = "ghcr.io/saleor/storefront:3.12"
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
  default     = "1000m"
}

variable "memory_request" {
  description = "Memory request for storefront container"
  type        = string
  default     = "2Gi"
}

variable "cpu_request" {
  description = "CPU request for storefront container"
  type        = string
  default     = "1000m"
}

variable "ingress_enabled" {
  description = "Enable ingress for storefront"
  type        = bool
  default     = false
}

variable "public_access" {
  description = "Enable public LoadBalancer access"
  type        = bool
  default     = false
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
  description = "Pre-built storefront Docker image"
  type        = string
  default     = "ghcr.io/saleor/saleor-kubernetes/storefront:latest"
}
