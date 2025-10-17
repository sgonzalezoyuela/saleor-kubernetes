resource "kubernetes_deployment" "saleor_worker" {
  metadata {
    name      = "saleor-worker"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-worker"
        "app.kubernetes.io/component" = "worker"
      }
    )
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "saleor-worker"
      }
    }

    template {
      metadata {
        labels = {
          app   = "saleor-worker"
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
          name    = "wait-for-api"
          image   = "busybox:1.35"
          command = ["sh", "-c"]
          args = [<<-EOT
          echo "Waiting for saleor-api to be ready... ${local.computed_api_host}:8000"
            until nc -z ${local.computed_api_host} 8000; do
              echo "Waiting for ${local.computed_api_host}:8000"
              sleep 5
            done
            echo "saleor-api is ready!"
          EOT
          ]
        }

        container {
          name    = "worker"
          image   = local.saleor_image
          command = ["celery", "-A", "saleor", "--app=saleor.celeryconf:app", "worker", "--loglevel=info", "-B"]

          resources {
            limits = {
              memory = "512Gi"
              cpu    = "500m"
            }
            requests = {
              memory = "256Mi"
              cpu    = "256m"
            }
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
    kubernetes_deployment.saleor_api
  ]
}
