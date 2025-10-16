locals {
  common_labels = merge(
    {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "saleor"
      "environment"                  = var.environment
    }
  )

  storefront_lb_ip = var.enabled && var.public_access && var.environment == "gke" ? try(kubernetes_service.saleor_storefront[0].status[0].load_balancer[0].ingress[0].ip, "") : ""

  computed_storefront_url = local.storefront_lb_ip != "" ? "http://storefront.${local.storefront_lb_ip}.nip.io:3000" : var.storefront_url
}

