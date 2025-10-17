resource "kubernetes_deployment" "saleor_db" {
  metadata {
    name      = "saleor-db"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-db"
        "app.kubernetes.io/component" = "database"
      }
    )
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "saleor-db"
      }
    }

    template {
      metadata {
        labels = {
          app   = "saleor-db"
          tier  = "backend"
          group = "saleor-platform"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = local.postgres_image

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
            container_port = 5432
          }

          env {
            name  = "POSTGRES_USER"
            value = local.db_user
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = "changeme"
          }

          env {
            name  = "POSTGRES_DB"
            value = local.db_name
          }

          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data"
          }

          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
            sub_path   = "pgdata"
          }

          volume_mount {
            name       = "init-script"
            mount_path = "/docker-entrypoint-initdb.d/replica_user.sql"
            sub_path   = "replica_user.sql"
            read_only  = true
          }
        }

        volume {
          name = "postgres-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.saleor_db.metadata[0].name
          }
        }

        volume {
          name = "init-script"
          config_map {
            name = kubernetes_config_map.db_init_script.metadata[0].name
          }
        }

      }
    }
  }

}

resource "kubernetes_service" "saleor_db" {
  metadata {
    name      = "saleor-db"
    namespace = var.namespace
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-db"
        "app.kubernetes.io/component" = "database"
      }
    )
  }

  spec {
    selector = {
      app = "saleor-db"
    }

    port {
      port        = 5432
      target_port = 5432
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
