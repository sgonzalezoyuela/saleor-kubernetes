resource "kubernetes_deployment" "saleor_mailpit" {
  metadata {
    name      = "saleor-mailpit"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-mailpit"
        "app.kubernetes.io/component" = "mail"
      }
    )
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "saleor-mailpit"
      }
    }

    template {
      metadata {
        labels = {
          app = "saleor-mailpit"
        }
      }

      spec {
        container {
          name  = "mailpit"
          image = local.mailpit_image

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
            name           = "smtp"
            container_port = 1025
          }

          port {
            name           = "web"
            container_port = 8025
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "saleor_mailpit" {
  metadata {
    name      = "saleor-mailpit"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-mailpit"
        "app.kubernetes.io/component" = "mail"
      }
    )
  }

  spec {
    selector = {
      app = "saleor-mailpit"
    }

    port {
      name        = "smtp"
      port        = 1025
      target_port = 1025
      protocol    = "TCP"
    }

    port {
      name        = "web"
      port        = 8025
      target_port = 8025
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

