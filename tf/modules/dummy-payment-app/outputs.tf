output "service_name" {
  description = "Dummy Payment App service name"
  value       = var.enabled ? kubernetes_service.payment_app[0].metadata[0].name : ""
}

output "app_url" {
  description = "Internal app URL"
  value       = var.enabled ? "http://dummy-payment-app:${var.app_port}" : ""
}
