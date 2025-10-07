resource "kubernetes_config_map" "saleor_common_env" {
  metadata {
    name      = "saleor-common-env"
    namespace = var.namespace
    labels    = local.common_labels
  }

  data = {
    CELERY_BROKER_URL           = "redis://${local.redis_host}:${local.redis_port}/1"
    DATABASE_URL                = "postgres://${local.db_user}:${var.postgres_password}@${local.db_host}:${local.db_port}/${local.db_name}"
    DEFAULT_FROM_EMAIL          = "noreply@example.com"
    EMAIL_URL                   = "smtp://saleor-mailpit:1025"
    SECRET_KEY                  = var.saleor_secret_key
    OTEL_SERVICE_NAME           = "saleor"
    OTEL_TRACES_EXPORTER        = "otlp"
    OTEL_EXPORTER_OTLP_ENDPOINT = "http://saleor-jaeger:4317"
  }
}

resource "kubernetes_config_map" "saleor_backend_env" {
  metadata {
    name      = "saleor-backend-env"
    namespace = var.namespace
    labels    = local.common_labels
  }

  data = {
    DEFAULT_CHANNEL_SLUG              = "default-channel"
    HTTP_IP_FILTER_ALLOW_LOOPBACK_IPS = "True"
    HTTP_IP_FILTER_ENABLED            = "True"
    PUBLIC_URL                        = "${var.api_protocol}://${var.api_host}:${var.api_port}"
  }
}

resource "kubernetes_config_map" "db_init_script" {
  metadata {
    name      = "db-init-script"
    namespace = var.namespace
    labels    = local.common_labels
  }

  data = {
    "replica_user.sql" = <<-EOT
      -- Script being executed on DB init, creates read only user
      -- for replicas purposes.
      CREATE USER saleor_read_only WITH PASSWORD 'saleor';
      GRANT CONNECT ON DATABASE saleor TO saleor_read_only;
      GRANT USAGE ON SCHEMA public TO saleor_read_only;
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO saleor_read_only;
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO saleor_read_only;
    EOT
  }
}

