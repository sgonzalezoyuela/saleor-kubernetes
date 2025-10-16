output "storefront_service_name" {
  description = "Saleor Storefront service name"
  value       = var.enabled ? kubernetes_service.saleor_storefront[0].metadata[0].name : ""
}

output "storefront_endpoint" {
  description = "Storefront endpoint URL"
  value       = var.enabled ? local.computed_storefront_url : ""
}

output "storefront_lb_ip" {
  description = "Storefront LoadBalancer IP (if public_access enabled)"
  value       = local.storefront_lb_ip
}

