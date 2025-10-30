# Example configuration for Google Kubernetes Engine (GKE)
namespace        = "saleor-demo"
environment      = "gke" # Used to confgure GKE specific options like services public access
create_namespace = true

# Image versions
saleor_image_tag    = "3.21"
dashboard_image_tag = "3.21"

storefront_image_tag = "3.21"
storefront_image = "ghcr.io/sgonzalezoyuela/saleor-kubernetes/saleor-storefront"

payment_app_image_tag = "3.21"
payment_app_image = "ghcr.io/sgonzalezoyuela/saleor-kubernetes/saleor-payment-app"

# Storage configuration for GKE
create_storage_class    = false
storage_class_name      = "standard-rwo"
storage_allow_expansion = true
storage_parameters = {
  type = "pd-standard" # or "pd-ssd" for SSD
}

# Public access
public_access = false
