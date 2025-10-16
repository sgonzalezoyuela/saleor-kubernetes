resource "kubernetes_storage_class" "saleor" {
  count = var.create_storage_class ? 1 : 0

  metadata {
    name = var.storage_class_name
    labels = merge(
      local.common_labels,
      {
        "app.kubernetes.io/name"      = "saleor-storage"
        "app.kubernetes.io/component" = "storage"
      }
    )
  }

  storage_provisioner    = var.storage_provisioner
  reclaim_policy         = var.storage_reclaim_policy
  volume_binding_mode    = var.storage_volume_binding_mode
  allow_volume_expansion = var.storage_allow_expansion

  parameters = var.storage_parameters
}