# Environment-specific configuration for talos
namespace           = "saleor-talos"
environment         = "talos"
create_namespace    = true

# Storage configuration
storage_provisioner         ="rancher.io/local-path"

# Ingress configuration
ingress_enabled     = true
ingress_class       = "nginx"
ingress_tls_enabled = true
ingress_tls_secret  = "saleor-tls"
ingress_cert_issuer = "atricore-ca"

# Store front API:
api_host        = "saleor-api.10.0.3.40.nip.io"
api_port        = 30080
api_protocol    = "http"
storefront_api_url   = "http://saleor-api.10.0.3.40.nip.io:30080/graphql/"

dashboard_host  = "dashboard.saleor.talos.local"
jaeger_host     = "jaeger.saleor.talos.local"
mailpit_host    = "mailpit.saleor.talos.local"
storefront_host = "storefront.saleor.talos.local"

# Storefront configuration
storefront_enabled   = true
storefront_image     = "ghcr.io/sgonzalezoyuela/saleor-storefront:latest"
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
