locals {
  common_labels = merge(
    {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "saleor"
      "environment"                   = var.environment
    },
    var.environment_labels
  )
  
  saleor_image     = "ghcr.io/saleor/saleor:${var.saleor_image_tag}"
  dashboard_image  = "ghcr.io/saleor/saleor-dashboard:${var.dashboard_image_tag}"
  postgres_image   = "library/postgres:${var.postgres_version}"
  redis_image      = "redis:${var.redis_version}"
  jaeger_image     = "jaegertracing/all-in-one:latest"
  mailpit_image    = "axllent/mailpit:latest"
  
  db_name     = "saleor"
  db_user     = "saleor"
  db_host     = "saleor-db"
  db_port     = "5432"
  redis_host  = "saleor-redis"
  redis_port  = "6379"
}