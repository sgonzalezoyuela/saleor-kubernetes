resource "kubernetes_deployment" "saleor_storefront" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "saleor-storefront"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-storefront"
        "app.kubernetes.io/component" = "frontend"
      }
    )
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "saleor-storefront"
      }
    }

    template {
      metadata {
        labels = {
          app = "saleor-storefront"
        }
      }

      spec {
        hostname = "storefront"
        container {
          name    = "storefront"
          image   = var.image
          command = ["sh", "-c"]
          args = [<<-EOT
              echo "installing ..."
              apk add git pnpm
              git clone https://github.com/saleor/storefront.git
              cd storefront
              echo NEXT_PUBLIC_SALEOR_API_URL=${var.saleor_api_url} > .env
              echo NEXT_PUBLIC_STOREFRONT_URL=${local.computed_storefront_url} >> .env
              pnpm i
              echo "building ..."
                
              echo "Waiting for saleor-api to be ready..."
              until wget --spider --timeout=5 --tries=1 --no-check-certificate "${var.saleor_api_url}" 2>/dev/null; do
                echo "Waiting for API at ${var.saleor_api_url}..."
                sleep 5
              done
              echo "API is ready!"

              echo "saleor-api is ready!"
              pnpm build
              echo "starting ..."
              pnpm start
          EOT
          ]

          port {
            container_port = 3000
          }

          env {
            name  = "NEXT_PUBLIC_SALEOR_API_URL"
            value = var.saleor_api_url
          }

          env {
            name  = "NEXT_PUBLIC_STOREFRONT_URL"
            value = local.computed_storefront_url
          }

          dynamic "env" {
            for_each = var.app_token != "" ? [1] : []
            content {
              name  = "SALEOR_APP_TOKEN"
              value = var.app_token
            }
          }

          # Add any additional environment variables
          dynamic "env" {
            for_each = var.env_vars
            content {
              name  = env.key
              value = env.value
            }
          }

          resources {
            limits = {
              memory            = var.memory_limit
              cpu               = var.cpu_limit
              ephemeral-storage = "2Gi"
            }
            requests = {
              memory            = var.memory_request
              cpu               = var.cpu_request
              ephemeral-storage = "2Gi"
            }
          }

        }
      }
    }
  }

  depends_on = [
    kubernetes_service.saleor_storefront
  ]
}

resource "kubernetes_service" "saleor_storefront" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "saleor-storefront"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-storefront"
        "app.kubernetes.io/component" = "frontend"
      }
    )

    annotations = var.public_access && var.environment == "gke" ? {} : {
      "networking.gke.io/load-balancer-type" = "Internal"
    }
  }

  spec {
    selector = {
      app = "saleor-storefront"
    }

    port {
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }

    type = var.public_access ? "LoadBalancer" : "ClusterIP"
  }

  wait_for_load_balancer = var.public_access && var.environment == "gke" ? true : false
}
