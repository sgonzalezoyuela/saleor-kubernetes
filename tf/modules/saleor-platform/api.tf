resource "kubernetes_deployment" "saleor_api" {
  metadata {
    name      = "saleor-api"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-api"
        "app.kubernetes.io/component" = "api"
      }
    )
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "saleor-api"
      }
    }

    template {
      metadata {
        labels = {
          app   = "saleor-api"
          tier  = "backend"
          group = "saleor-platform"
        }
      }

      spec {

        affinity {
          pod_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_labels = {
                    group = "saleor-platform"
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        init_container {
          name    = "migrate"
          image   = local.saleor_image
          command = ["python3", "manage.py", "migrate"]

          env {
            name  = "STATIC_URL" # Used during populatedb to create thumbnails and images
            value = "/static/"
          }

          env {
            name  = "DASHBOARD_URL"
            value = var.dashboard_url != "" ? var.dashboard_url : "https://${var.dashboard_host}/"
          }

          env {
            name  = "ALLOWED_HOSTS"
            value = "localhost,saleor-api,saleor-api:8000,${var.api_host},${var.api_host}:${var.api_port}"
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

          volume_mount {
            name       = "media-storage"
            mount_path = "/app/media"
          }
        }

        init_container {
          name    = "populatedb"
          image   = local.saleor_image
          command = ["python3", "manage.py", "populatedb", "--createsuperuser"]

          env {
            name  = "DASHBOARD_URL"
            value = var.dashboard_url != "" ? var.dashboard_url : "https://${var.dashboard_host}/"
          }

          env {
            name  = "ALLOWED_HOSTS"
            value = "localhost,saleor-api,saleor-api:8000,${var.api_host},${var.api_host}:${var.api_port}"
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

          volume_mount {
            name       = "media-storage"
            mount_path = "/app/media"
          }
        }

        container {
          name  = "api"
          image = local.saleor_image

          port {
            container_port = 8000
          }

          env {
            name  = "DASHBOARD_URL"
            value = var.dashboard_url != "" ? var.dashboard_url : "https://${var.dashboard_host}/"
          }

          env {
            name  = "ALLOWED_HOSTS"
            value = "localhost,saleor-api,saleor-api:8000,${var.api_host},${var.api_host}:${var.api_port}"
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

          volume_mount {
            name       = "media-storage"
            mount_path = "/app/media"
          }

          stdin = true
          tty   = true
        }

        volume {
          name = "media-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.saleor_media.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_deployment.saleor_db,
    kubernetes_deployment.saleor_redis,
    kubernetes_deployment.saleor_jaeger
  ]
}

# main.tf (within your module)

resource "kubernetes_service" "saleor_api" {
  metadata {
    name      = "saleor-api"
    namespace = var.namespace # Assuming you have a namespace variable

    # Merges a map of common labels with labels specific to this resource
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-api",
        "app.kubernetes.io/component" = "api-service"
      }
    )

    # Directly uses the map variable for annotations as you requested
    annotations = var.api_service_annotations
  }

  spec {
    # This type, combined with the GKE annotation, creates the load balancer
    type = "LoadBalancer"

    # This should match the labels on your Saleor API pods
    selector = {
      app = "saleor-api"
    }

    port {
      port        = 8000
      target_port = 8000
      protocol    = "TCP"
    }
  }

}
