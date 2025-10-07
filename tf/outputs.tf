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
  value       = var.storefront_enabled ? module.saleor_storefront.storefront_service_name : ""
}

output "ingress_endpoints" {
  description = "Ingress endpoint URLs"
  value       = var.ingress_enabled ? module.saleor_platform.ingress_endpoints : {}
}
