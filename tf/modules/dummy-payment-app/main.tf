resource "kubernetes_deployment" "payment_app" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "dummy-payment-app"
    namespace = var.namespace
    labels    = local.common_labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "dummy-payment-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "dummy-payment-app"
        }
      }

      spec {

        container {
          name    = "app"
          image   = var.app_image
          command = ["sh", "-c"]
          args = [<<-EOT
              echo "installing ..."
              apk add git pnpm
              git clone https://github.com/saleor/dummy-payment-app.git
              cd dummy-payment-app

              echo "building ..."
              npm install --global corepack@latest
              corepack enable pnpm
              pnpm install

              echo "starting ..."
              pnpm dev
          EOT
          ]

          port {
            container_port = var.app_port
          }

          env {
            name  = "APP_API_BASE_URL"
            value = local.computed_payment_url
          }
          env {
            name  = "APP_IFRAME_BASE_URL"
            value = "${local.computed_payment_url}?saleorApiUrl=${var.saleor_api_url}/graphql/"
          }

          env {
            name  = "PORT"
            value = tostring(var.app_port)
          }

          resources {
            limits = {
              memory = "2Gi"
              cpu    = "2000m"
            }
            requests = {
              memory = "1Gi"
              cpu    = "1000m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "payment_app" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "dummy-payment-app"
    namespace = var.namespace
    labels    = local.common_labels

    annotations = var.public_access && var.environment == "gke" ? {} : {
      "networking.gke.io/load-balancer-type" = "Internal"
    }
  }

  spec {
    selector = {
      app = "dummy-payment-app"
    }

    port {
      port        = var.svc_port
      target_port = var.app_port
      protocol    = "TCP"
    }

    type = var.public_access ? "LoadBalancer" : "ClusterIP"
  }
}
