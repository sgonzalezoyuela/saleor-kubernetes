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
  default     = false
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

variable "environment_labels" {
  description = "Additional labels"
  type        = map(string)
  default     = {}
}
