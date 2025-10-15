# Environment-specific configuration for talos
namespace           = "saleor-demo"
environment         = "talos"
create_namespace    = true

# Image versions
saleor_image_tag    = "3.21"
dashboard_image_tag = "3.21"

# Storage configuration
storage_class_name          = "saleor-storage"  # Use existing local-path StorageClass
create_storage_class        = true
storage_provisioner         ="rancher.io/local-path"

# Storage sizes
db_storage_size            = "1Gi"
media_storage_size         = "1Gi"
redis_storage_size         = "1Gi"
media_storage_access_mode  = "ReadWriteOnce"

# Ingress configuration
ingress_enabled     = true
ingress_class       = "nginx"
ingress_tls_enabled = true
ingress_tls_secret  = "saleor-tls"
ingress_cert_issuer = "atricore-ca"

# Store front API:
api_host        = "saleor-api.saleor-demo.svc.cluster.local"
api_port        = 8000
api_protocol    = "http"

dashboard_host  = "dashboard.saleor.talos.local"
jaeger_host     = "jaeger.saleor.talos.local"
mailpit_host    = "mailpit.saleor.talos.local"
storefront_host = "storefront.saleor.talos.local"

# Storefront configuration
storefront_enabled   = true
storefront_url       = "http://localhost:3000"
storefront_app_token = ""  # Add your app token if needed
storefront_cpu_limit = "2000m"
storefront_memory_limit = "2Gi"
storefront_cpu_request = "2000m"
storefront_memory_request = "2Gi"

# Labels for talos environment
environment_labels = {
  "environment" = "talos"
  "team"        = "platform"
}

dummy_payment_app_enabled =  true
