locals {
  common_labels = merge(
    {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "saleor"
      "environment"                  = var.environment
    }
  )

  saleor_image    = "ghcr.io/saleor/saleor:${var.saleor_image_tag}"
  dashboard_image = "ghcr.io/saleor/saleor-dashboard:${var.dashboard_image_tag}"
  # these could be configured as vars if needed
  postgres_image = "library/postgres:15-alpine"
  redis_image    = "redis:7-alpine"
  jaeger_image   = "jaegertracing/all-in-one:latest"
  mailpit_image  = "axllent/mailpit:latest"

  db_name    = "saleor"
  db_user    = "saleor"
  db_host    = "saleor-db"
  db_port    = "5432"
  redis_host = "saleor-redis"
  redis_port = "6379"

  api_lb_ip       = var.public_access && var.environment == "gke" ? try(kubernetes_service.saleor_api.status[0].load_balancer[0].ingress[0].ip, "") : ""
  dashboard_lb_ip = var.public_access && var.environment == "gke" ? try(kubernetes_service.saleor_dashboard.status[0].load_balancer[0].ingress[0].ip, "") : ""

  # When public access is enabled in GKE, we use the public IP w/nip.io. This could to be updated for AWS and other clusters
  computed_api_host = local.api_lb_ip != "" ? "api.${local.api_lb_ip}.nip.io" : (
    var.public_access ? var.api_host : "saleor-api.${var.namespace}.svc.cluster.local"
  )
  computed_api_port = "8000"
  computed_api_url  = local.computed_api_port != "80" ? "http://${local.computed_api_host}:${local.computed_api_port}" : "http://${local.computed_api_host}"

  computed_dashboard_url = local.dashboard_lb_ip != "" ? "http://dashboard.${local.dashboard_lb_ip}.nip.io:3000" : (
    var.public_access ? var.dashboard_url : "http://localhost:3000"
  )
}

