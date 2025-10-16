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
  postgres_image  = "library/postgres:latest"
  redis_image     = "redis:latest"
  jaeger_image    = "jaegertracing/all-in-one:latest"
  mailpit_image   = "axllent/mailpit:latest"

  db_name    = "saleor"
  db_user    = "saleor"
  db_host    = "saleor-db"
  db_port    = "5432"
  redis_host = "saleor-redis"
  redis_port = "6379"

  api_lb_ip       = var.public_access && var.environment == "gke" ? try(kubernetes_service.saleor_api.status[0].load_balancer[0].ingress[0].ip, "") : ""
  dashboard_lb_ip = var.public_access && var.environment == "gke" ? try(kubernetes_service.saleor_dashboard.status[0].load_balancer[0].ingress[0].ip, "") : ""

  computed_api_host      = local.api_lb_ip != "" ? "${local.api_lb_ip}.nip.io" : var.api_host
  computed_dashboard_url = local.dashboard_lb_ip != "" ? "${var.api_protocol}://${local.dashboard_lb_ip}.nip.io:${var.api_port}" : var.dashboard_url
}

