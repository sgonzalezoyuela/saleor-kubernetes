resource "kubernetes_persistent_volume_claim" "saleor_db" {
  metadata {
    name      = "saleor-db-pvc"
    namespace = var.namespace
    labels    = local.common_labels
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }


    storage_class_name = var.create_storage_class ? kubernetes_storage_class.saleor[0].metadata[0].name : var.storage_class_name
  }

  # Don't wait for PVC to be bound when using WaitForFirstConsumer
  wait_until_bound = false
}

resource "kubernetes_persistent_volume_claim" "saleor_media" {
  metadata {
    name      = "saleor-media-pvc"
    namespace = var.namespace
    labels    = local.common_labels
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    storage_class_name = var.create_storage_class ? kubernetes_storage_class.saleor[0].metadata[0].name : var.storage_class_name
  }
  # Don't wait for PVC to be bound when using WaitForFirstConsumer
  wait_until_bound = false

}

resource "kubernetes_persistent_volume_claim" "saleor_redis" {
  metadata {
    name      = "saleor-redis-pvc"
    namespace = var.namespace
    labels    = local.common_labels
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    storage_class_name = var.create_storage_class ? kubernetes_storage_class.saleor[0].metadata[0].name : var.storage_class_name
  }
  # Don't wait for PVC to be bound when using WaitForFirstConsumer
  wait_until_bound = false

}
