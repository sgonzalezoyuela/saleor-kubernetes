locals {
  common_labels = merge(
    {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "saleor"
      "app.kubernetes.io/name"       = "dummy-payment-app"
      "app.kubernetes.io/component"  = "payment"
      "environment"                   = var.environment
    },
    var.environment_labels
  )
}
