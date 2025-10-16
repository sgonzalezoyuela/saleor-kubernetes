# Environment-specific configuration for talos
namespace        = "saleor-demo"
environment      = "talos"
create_namespace = true

# Image versions
saleor_image_tag    = "3.21"
dashboard_image_tag = "3.21"

# Storage configuration
storage_class_name   = "saleor-storage" # Use existing local-path StorageClass
create_storage_class = true
storage_provisioner  = "rancher.io/local-path"

# Store front API:
api_host     = "saleor-api.saleor-demo.svc.cluster.local"
api_port     = 8000
api_protocol = "http"

# Storefront configuration
storefront_url = "http://localhost:3000"

dummy_payment_app_enabled = true
