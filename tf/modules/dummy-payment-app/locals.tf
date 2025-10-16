locals {
  common_labels = merge(
    {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "saleor"
      "app.kubernetes.io/name"       = "dummy-payment-app"
      "app.kubernetes.io/component"  = "payment"
      "environment"                  = var.environment
    }
  )

  payment_lb_ip = var.enabled && var.public_access && var.environment == "gke" ? try(kubernetes_service.payment_app[0].status[0].load_balancer[0].ingress[0].ip, "") : ""

  computed_payment_url = local.payment_lb_ip != "" ? "http://${local.payment_lb_ip}.nip.io:${var.app_port}" : "http://dummy-payment-app:${var.app_port}"
}
