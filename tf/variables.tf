variable "namespace" {
  description = "Kubernetes namespace for Saleor deployment"
  type        = string
  default     = "saleor"
}

variable "environment" {
  description = "Environment name (e.g., gke, talos)"
  type        = string
  default     = "dev"
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = true
}

variable "saleor_image_tag" {
  description = "Saleor backend image tag"
  type        = string
  default     = "3.21"
}

variable "dashboard_image_tag" {
  description = "Saleor dashboard image tag"
  type        = string
  default     = "latest"
}

variable "create_storage_class" {
  description = "Whether to create a new StorageClass resource"
  type        = bool
  default     = false
}

variable "storage_class_name" {
  description = "Name of the StorageClass to create"
  type        = string
  default     = "saleor-storage"
}

variable "storage_provisioner" {
  description = "Storage provisioner (e.g., rancher.io/local-path, kubernetes.io/gce-pd, ebs.csi.aws.com)"
  type        = string
  default     = ""
}

variable "storage_reclaim_policy" {
  description = "Reclaim policy for the StorageClass"
  type        = string
  default     = "Delete"
}

variable "storage_volume_binding_mode" {
  description = "Volume binding mode (Immediate or WaitForFirstConsumer)"
  type        = string
  default     = "WaitForFirstConsumer"
}

variable "storage_allow_expansion" {
  description = "Allow volume expansion"
  type        = bool
  default     = true
}

variable "storage_parameters" {
  description = "Storage provisioner-specific parameters"
  type        = map(string)
  default     = {}
}

variable "ingress_enabled" {
  description = "Enable ingress for external access"
  type        = bool
  default     = false
}

variable "ingress_class" {
  description = "Ingress class name"
  type        = string
  default     = "nginx"
}

variable "api_protocol" {
  description = "API protocol (http/https)"
  type        = string
  default     = "http"
}
variable "api_host" {
  description = "API public hostname"
  type        = string
  default     = "api.saleor.local"
}
variable "api_port" {
  description = "API port"
  type        = number
  default     = 8000
}

variable "api_service_annotations" {
  description = "A map of annotations to apply to the service metadata."
  type        = map(string)
  default     = {}
}

variable "storefront_image" {
  description = "Saleor Storefront Docker image"
  type        = string
  default     = "node:20-alpine"
}

variable "storefront_url" {
  description = "Public URL for the storefront"
  type        = string
  default     = ""
}

variable "storefront_host" {
  description = "Storefront ingress hostname"
  type        = string
  default     = "storefront.saleor.local"
}

variable "storefront_env_vars" {
  description = "Additional environment variables for storefront"
  type        = map(string)
  default     = {}
}

variable "dummy_payment_app_enabled" {
  description = "Enable Dummy Payment App deployment"
  type        = bool
  default     = true
}
