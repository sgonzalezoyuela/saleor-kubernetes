output "storefront_service_name" {
  description = "Saleor Storefront service name"
  value       = var.enabled ? kubernetes_service.saleor_storefront[0].metadata[0].name : ""
}

output "storefront_endpoint" {
  description = "Storefront endpoint URL"
  value       = var.enabled ? "http://${var.host}" : ""
}

