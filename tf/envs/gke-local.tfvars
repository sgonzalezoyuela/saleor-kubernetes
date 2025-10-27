# Example configuration for Google Kubernetes Engine (GKE)
namespace        = "saleor-demo"
environment      = "gke" # Used to confgure GKE specific options like services public access
create_namespace = true

# Image versions
saleor_image_tag    = "3.21"
dashboard_image_tag = "3.21"

# Git references for apps built from source
storefront_git_ref  = "3481bbb0e44e85aff083cace1421536c09e7bb9e" # 09/25/25
payment_app_git_ref = "f63c209035177f62dba63839fb61927fe94f81f0" # 08/06/25

# Storage configuration for GKE
create_storage_class    = false
storage_class_name      = "standard-rwo"
storage_allow_expansion = true
storage_parameters = {
  type = "pd-standard" # or "pd-ssd" for SSD
}

# Public access
public_access = false


