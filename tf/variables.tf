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

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15-alpine"
}

variable "redis_version" {
  description = "Redis version"
  type        = string
  default     = "7-alpine"
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

variable "db_storage_size" {
  description = "Database storage size"
  type        = string
  default     = "1Gi"
}

variable "media_storage_size" {
  description = "Media storage size"
  type        = string
  default     = "1Gi"
}

variable "media_storage_access_mode" {
  description = "Media storage access mode"
  type        = string
  default     = "ReadWriteMany"
}
variable "redis_storage_size" {
  description = "Redis storage size"
  type        = string
  default     = "1Gi"
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

variable "ingress_tls_enabled" {
  description = "Enable TLS for ingress"
  type        = bool
  default     = false
}

variable "ingress_tls_secret" {
  description = "TLS secret name for ingress"
  type        = string
  default     = "saleor-tls"
}

variable "ingress_cert_issuer" {
  description = "Cert-manager issuer name"
  type        = string
  default     = ""
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
  default     = {} # It's good practice to provide an empty default
}

variable "dashboard_host" {
  description = "Dashboard ingress hostname"
  type        = string
  default     = "dashboard.saleor.local"
}
variable "dashboard_url" {
  description = "Dashboard ingress hostname"
  type        = string
  default     = "http://localhost:3000"
}

variable "jaeger_host" {
  description = "Jaeger ingress hostname"
  type        = string
  default     = "jaeger.saleor.local"
}

variable "mailpit_host" {
  description = "Mailpit ingress hostname"
  type        = string
  default     = "mailpit.saleor.local"
}

variable "saleor_secret_key" {
  description = "Saleor secret key for Django"
  type        = string
  default     = "changeme"
  sensitive   = true
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  default     = "saleor"
  sensitive   = true
}

variable "environment_labels" {
  description = "Additional labels for all resources"
  type        = map(string)
  default     = {}
}
# ====================================
# Storefront variables
# ====================================
variable "storefront_enabled" {
  description = "Enable Saleor Storefront deployment"
  type        = bool
  default     = true
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

variable "storefront_app_token" {
  description = "Saleor app token for storefront"
  type        = string
  default     = ""
  sensitive   = true
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

variable "storefront_memory_limit" {
  description = "Memory limit for storefront"
  type        = string
  default     = "2Gi"
}

variable "storefront_cpu_limit" {
  description = "CPU limit for storefront"
  type        = string
  default     = "2000m"
}

variable "storefront_memory_request" {
  description = "Memory request for storefront"
  type        = string
  default     = "2Gi"
}

variable "storefront_cpu_request" {
  description = "CPU request for storefront"
  type        = string
  default     = "2000m"
}


variable "dummy_payment_app_enabled" {
  description = "Enable Dummy Payment App deployment"
  type        = bool
  default     = true
}
