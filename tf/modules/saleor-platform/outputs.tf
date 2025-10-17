output "api_service_name" {
  description = "Saleor API service name"
  value       = kubernetes_service.saleor_api.metadata[0].name
}

output "dashboard_service_name" {
  description = "Saleor Dashboard service name"
  value       = kubernetes_service.saleor_dashboard.metadata[0].name
}

output "database_service_name" {
  description = "Database service name"
  value       = kubernetes_service.saleor_db.metadata[0].name
}

output "redis_service_name" {
  description = "Redis service name"
  value       = kubernetes_service.saleor_redis.metadata[0].name
}

output "jaeger_service_name" {
  description = "Jaeger service name"
  value       = kubernetes_service.saleor_jaeger.metadata[0].name
}

output "mailpit_service_name" {
  description = "Mailpit service name"
  value       = kubernetes_service.saleor_mailpit.metadata[0].name
}

output "api_lb_ip" {
  description = "API LoadBalancer IP (if public_access enabled)"
  value       = local.api_lb_ip
}

output "dashboard_lb_ip" {
  description = "Dashboard LoadBalancer IP (if public_access enabled)"
  value       = local.dashboard_lb_ip
}

output "api_url" {
  description = "Computed API URL"
  value       = local.computed_api_url
}

output "dashboard_url" {
  description = "Computed Dashboard URL"
  value       = local.computed_dashboard_url
}

