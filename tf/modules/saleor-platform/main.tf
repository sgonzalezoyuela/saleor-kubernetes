# Main module file that ties everything together
# All resources are defined in separate files for clarity:
# - configmaps.tf: Environment configuration
# - storage.tf: Persistent volume claims
# - database.tf: PostgreSQL deployment
# - redis.tf: Redis cache deployment
# - api.tf: Saleor API deployment
# - worker.tf: Celery worker deployment  
# - dashboard.tf: Frontend dashboard deployment
# - monitoring.tf: Jaeger tracing deployment
# - mail.tf: Mailpit SMTP server deployment
# - ingress.tf: Ingress configuration for external access