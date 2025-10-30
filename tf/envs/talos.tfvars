# Environment-specific configuration for talos
namespace        = "saleor-demo"
environment      = "talos"
create_namespace = true

# Image versions
saleor_image_tag    = "3.21"
dashboard_image_tag = "3.21"
storefront_image_tag = "3.21"
payment_app_image_tag = "3.21"

payment_app_image = "ghcr.io/sgonzalezoyuela/saleor-kubernetes/saleor-payment-app"
storefront_image = "ghcr.io/sgonzalezoyuela/saleor-kubernetes/saleor-storefront"

# Storage configuration
storage_class_name         = "saleor-storage" # Use existing local-path StorageClass
create_storage_class       = true
storage_provisioner        = "rancher.io/local-path"
media_storage_access_modes = ["ReadWriteOnce"]

# Store front API:
api_host = "saleor-api.saleor-demo.svc.cluster.local"
api_port = 8000

# Storefront configuration
storefront_url = "http://localhost:3000"
