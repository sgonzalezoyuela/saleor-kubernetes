output "service_name" {
  description = "Dummy Payment App service name"
  value       = var.enabled ? kubernetes_service.payment_app[0].metadata[0].name : ""
}

output "app_url" {
  description = "Computed app URL"
  value       = var.enabled ? local.computed_payment_url : ""
}

output "payment_lb_ip" {
  description = "Payment App LoadBalancer IP (if public_access enabled)"
  value       = local.payment_lb_ip
}
