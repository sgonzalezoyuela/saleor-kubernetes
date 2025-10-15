# Example configuration for Google Kubernetes Engine (GKE)
namespace           = "saleor-demo"
environment         = "gke"
create_namespace    = true

# Image versions
saleor_image_tag    = "3.21"
dashboard_image_tag = "3.21"

# Storage configuration for GKE
create_storage_class        = false
storage_class_name          = "standard-rwx"
storage_allow_expansion     = true
storage_parameters = {
  type             = "pd-standard"  # or "pd-ssd" for SSD
}

# Storage sizes
db_storage_size     = "1Gi"
media_storage_size  = "1Gi"
redis_storage_size  = "1Gi"

# Saleor API
api_host        = "saleor-api.saleor-demo.svc.cluster.local"
api_port        = 8000
api_protocol    = "http"
# Here you pass the specific GKE annotation
#api_service_annotations = {
#    "cloud.google.com/load-balancer-type" = "Internal"
#}


# Ingress configuration
ingress_enabled     = false

# Hostnames
dashboard_host = "dashboard.saleor.example.com"
jaeger_host    = "jaeger.saleor.example.com"
mailpit_host   = "mailpit.saleor.example.com"

# IMPORTANT: Change these for production
saleor_secret_key = "changeme"
postgres_password = "changeme"

# Labels
environment_labels = {
  "environment" = "gke"
  "cloud"       = "gcp"
}

# Storefront
storefront_enabled   = true
