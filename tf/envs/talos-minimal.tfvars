# Environment-specific configuration for talos
namespace        = "saleor-talos"
environment      = "talos"
create_namespace = true

# Storage configuration
storage_provisioner = "rancher.io/local-path"

# Ingress configuration
ingress_enabled     = true
ingress_class       = "nginx"
ingress_tls_enabled = true
ingress_tls_secret  = "saleor-tls"
ingress_cert_issuer = "atricore-ca"

# Store front API:
api_host           = "saleor-api.10.0.3.40.nip.io"
api_port           = 30080
api_protocol       = "http"
storefront_api_url = "http://saleor-api.10.0.3.40.nip.io:30080/graphql/"

# Storefront configuration
storefront_enabled   = true
storefront_image     = "ghcr.io/sgonzalezoyuela/saleor-storefront:latest"
storefront_url       = "http://localhost:3000"
storefront_app_token = "" # Add your app token if needed

# Labels for talos environment
environment_labels = {
  "environment" = "talos"
  "team"        = "platform"
}
