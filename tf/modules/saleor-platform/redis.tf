resource "kubernetes_deployment" "saleor_redis" {
  metadata {
    name      = "saleor-redis"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-redis"
        "app.kubernetes.io/component" = "cache"
      }
    )
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "saleor-redis"
      }
    }

    template {
      metadata {
        labels = {
          app   = "saleor-redis"
          tier  = "backend"
          group = "saleor-platform"
        }
      }

      spec {
        container {
          name  = "redis"
          image = local.redis_image

          resources {
            limits = {
              memory = "256Mi"
              cpu    = "500m"
            }
            requests = {
              memory = "128Mi"
              cpu    = "100m"
            }
          }

          port {
            container_port = 6379
          }

          volume_mount {
            name       = "redis-data"
            mount_path = "/data"
          }
        }

        volume {
          name = "redis-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.saleor_redis.metadata[0].name
          }
        }
      }
    }
  }

}

resource "kubernetes_service" "saleor_redis" {
  metadata {
    name      = "saleor-redis"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-redis"
        "app.kubernetes.io/component" = "cache"
      }
    )
  }

  spec {
    selector = {
      app = "saleor-redis"
    }

    port {
      port        = 6379
      target_port = 6379
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
