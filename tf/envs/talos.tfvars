# Environment-specific configuration for talos
namespace        = "saleor-demo"
environment      = "talos"
create_namespace = true

# Image versions
saleor_image_tag    = "3.21"
dashboard_image_tag = "3.21"

# Git references for apps built from source
storefront_git_ref  = "3481bbb0e44e85aff083cace1421536c09e7bb9e" # 09/25/25
payment_app_git_ref = "f63c209035177f62dba63839fb61927fe94f81f0" # 08/06/25

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
