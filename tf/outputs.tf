output "namespace" {
  description = "The namespace where Saleor is deployed"
  value       = var.namespace
}

output "api_service" {
  description = "API service name"
  value       = module.saleor_platform.api_service_name
}

output "dashboard_service" {
  description = "Dashboard service name"
  value       = module.saleor_platform.dashboard_service_name
}

output "database_service" {
  description = "Database service name"
  value       = module.saleor_platform.database_service_name
}

output "redis_service" {
  description = "Redis service name"
  value       = module.saleor_platform.redis_service_name
}

output "storefront_service" {
  description = "Storefront service name"
  value       = module.saleor_storefront.storefront_service_name
}

output "api_url" {
  description = "Saleor API URL (with nip.io if public_access enabled)"
  value       = module.saleor_platform.api_url
}

output "dashboard_url" {
  description = "Saleor Dashboard URL (with nip.io if public_access enabled)"
  value       = module.saleor_platform.dashboard_url
}

output "storefront_url" {
  description = "Saleor Storefront URL (with nip.io if public_access enabled)"
  value       = module.saleor_storefront.storefront_endpoint
}

output "payment_app_url" {
  description = "Dummy Payment App URL (with nip.io if public_access enabled)"
  value       = module.dummy_payement_app.app_url
}

output "api_lb_ip" {
  description = "API LoadBalancer public IP (GKE only)"
  value       = module.saleor_platform.api_lb_ip
}

output "dashboard_lb_ip" {
  description = "Dashboard LoadBalancer public IP (GKE only)"
  value       = module.saleor_platform.dashboard_lb_ip
}

output "storefront_lb_ip" {
  description = "Storefront LoadBalancer public IP (GKE only)"
  value       = module.saleor_storefront.storefront_lb_ip
}

output "payment_lb_ip" {
  description = "Payment App LoadBalancer public IP (GKE only)"
  value       = module.dummy_payement_app.payment_lb_ip
}
