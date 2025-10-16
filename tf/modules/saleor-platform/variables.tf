variable "namespace" {
  description = "Kubernetes namespace for deployment"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "saleor_image_tag" {
  description = "Saleor backend image tag"
  type        = string
}

variable "dashboard_image_tag" {
  description = "Saleor dashboard image tag"
  type        = string
}

variable "create_storage_class" {
  description = "Whether to create a StorageClass resource"
  type        = bool
  default     = false
}

variable "storage_class_name" {
  description = "Name of the StorageClass to create"
  type        = string
  default     = "saleor-storage"
}

variable "storage_provisioner" {
  description = "Storage provisioner (e.g., rancher.io/local-path, kubernetes.io/gce-pd, kubernetes.io/aws-ebs)"
  type        = string
  default     = ""
}

variable "storage_reclaim_policy" {
  description = "Reclaim policy for the StorageClass"
  type        = string
  default     = "Delete"
}

variable "storage_volume_binding_mode" {
  description = "Volume binding mode for the StorageClass (Immediate or WaitForFirstConsumer)"
  type        = string
  default     = "Immediate"
}

variable "storage_allow_expansion" {
  description = "Allow volume expansion"
  type        = bool
  default     = true
}

variable "storage_parameters" {
  description = "Storage class parameters"
  type        = map(string)
  default     = {}
}

variable "ingress_enabled" {
  description = "Enable ingress"
  type        = bool
}

variable "ingress_class" {
  description = "Ingress class name"
  type        = string
}

variable "api_host" {
  description = "API hostname"
  type        = string
}

variable "api_protocol" {
  description = "API protocol"
  type        = string
  default     = "http"
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


variable "dashboard_url" {
  description = "dashboard URL"
  type        = string
  default     = "http://localhost:3000"
}

variable "public_access" {
  description = "Enable public LoadBalancer access"
  type        = bool
  default     = false
}
