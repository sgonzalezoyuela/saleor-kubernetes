resource "kubernetes_deployment" "saleor_jaeger" {
  metadata {
    name      = "saleor-jaeger"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-jaeger"
        "app.kubernetes.io/component" = "monitoring"
      }
    )
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "saleor-jaeger"
      }
    }

    template {
      metadata {
        labels = {
          app   = "saleor-jaeger"
          tier  = "backend"
          group = "saleor-platform"
        }
      }

      spec {
        container {
          name  = "jaeger"
          image = local.jaeger_image

          resources {
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
            requests = {
              memory = "256Mi"
              cpu    = "100m"
            }
          }

          port {
            name           = "query"
            container_port = 16686
          }

          port {
            name           = "otlp"
            container_port = 4317
          }

          port {
            name           = "otlp-http"
            container_port = 4318
          }

          env {
            name  = "COLLECTOR_OTLP_ENABLED"
            value = "true"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "saleor_jaeger" {
  metadata {
    name      = "saleor-jaeger"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-jaeger"
        "app.kubernetes.io/component" = "monitoring"
      }
    )
  }

  spec {
    selector = {
      app = "saleor-jaeger"
    }

    port {
      name        = "query"
      port        = 16686
      target_port = 16686
      protocol    = "TCP"
    }

    port {
      name        = "otlp"
      port        = 4317
      target_port = 4317
      protocol    = "TCP"
    }

    port {
      name        = "otlp-http"
      port        = 4318
      target_port = 4318
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
