resource "kubernetes_deployment" "saleor_dashboard" {
  metadata {
    name      = "saleor-dashboard"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-dashboard"
        "app.kubernetes.io/component" = "frontend"
      }
    )
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "saleor-dashboard"
      }
    }

    template {
      metadata {
        labels = {
          app   = "saleor-dashboard"
          tier  = "backend"
          group = "saleor-platform"
        }
      }

      spec {
        container {
          name  = "dashboard"
          image = local.dashboard_image

          resources {
            limits = {
              memory = "2048Mi"
              cpu    = "500m"
            }
            requests = {
              memory = "2048Mi"
              cpu    = "100m"
            }
          }

          port {
            container_port = 80
          }

          env {
            name  = "API_URL"
            value = "${var.api_protocol}://${local.computed_api_host}:${var.api_port}/graphql/"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.saleor_common_env.metadata[0].name
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.saleor_backend_env.metadata[0].name
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_deployment.saleor_worker
  ]

}

resource "kubernetes_service" "saleor_dashboard" {
  metadata {
    name      = "saleor-dashboard"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-dashboard"
        "app.kubernetes.io/component" = "frontend"
      }
    )

    annotations = var.public_access && var.environment == "gke" ? {} : {
      "networking.gke.io/load-balancer-type" = "Internal"
    }
  }

  spec {
    selector = {
      app = "saleor-dashboard"
    }

    port {
      port        = 9000
      target_port = 80
      protocol    = "TCP"
    }

    type = var.public_access ? "LoadBalancer" : "ClusterIP"
  }

}
