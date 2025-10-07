provider "kubernetes" {
  # Configuration will be read from KUBECONFIG environment variable
  # If KUBECONFIG is not set, it will try ~/.kube/config
  # The provider automatically checks KUBECONFIG env var
}

resource "kubernetes_namespace" "saleor" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
    labels = merge(
      {
        name        = var.namespace
        environment = var.environment
      },
      var.environment_labels
    )
  }
}

module "saleor_platform" {
  source = "./modules/saleor-platform"

  namespace           = var.create_namespace ? kubernetes_namespace.saleor[0].metadata[0].name : var.namespace
  environment         = var.environment
  saleor_image_tag    = var.saleor_image_tag
  dashboard_image_tag = var.dashboard_image_tag
  postgres_version    = var.postgres_version
  redis_version       = var.redis_version

  # Storage configuration
  create_storage_class        = var.create_storage_class
  storage_class_name          = var.storage_class_name
  storage_provisioner         = var.storage_provisioner
  storage_reclaim_policy      = var.storage_reclaim_policy
  storage_volume_binding_mode = var.storage_volume_binding_mode
  storage_allow_expansion     = var.storage_allow_expansion
  storage_parameters          = var.storage_parameters
  db_storage_size             = var.db_storage_size
  media_storage_size          = var.media_storage_size
  media_storage_access_mode   = var.media_storage_access_mode
  redis_storage_size          = var.redis_storage_size

  # URLs
  dashboard_url = var.dashboard_url

  # Ingress configuration
  ingress_enabled         = var.ingress_enabled
  ingress_class           = var.ingress_class
  ingress_tls_enabled     = var.ingress_tls_enabled
  ingress_tls_secret      = var.ingress_tls_secret
  ingress_cert_issuer     = var.ingress_cert_issuer
  api_host                = var.api_host
  api_port                = var.api_port
  api_protocol            = var.api_protocol
  api_service_annotations = var.api_service_annotations
  dashboard_host          = var.dashboard_host
  jaeger_host             = var.jaeger_host
  mailpit_host            = var.mailpit_host

  # Secrets
  saleor_secret_key = var.saleor_secret_key
  postgres_password = var.postgres_password

  # Labels
  environment_labels = var.environment_labels
}

module "saleor_storefront" {
  source = "./modules/saleor-storefront"

  namespace   = var.create_namespace ? kubernetes_namespace.saleor[0].metadata[0].name : var.namespace
  environment = var.environment

  # Storefront configuration
  enabled        = var.storefront_enabled
  image          = var.storefront_image
  saleor_api_url = "${var.api_protocol}://${var.api_host}:${var.api_port}/graphql/"
  storefront_url = var.storefront_url
  app_token      = var.storefront_app_token
  env_vars       = var.storefront_env_vars
  memory_limit   = var.storefront_memory_limit
  cpu_limit      = var.storefront_cpu_limit
  memory_request = var.storefront_memory_request
  cpu_request    = var.storefront_cpu_request

  # API service reference
  api_service_name = module.saleor_platform.api_service_name

  # Labels
  environment_labels = var.environment_labels

  depends_on = [
    module.saleor_platform
  ]
}

module "dummy_payement_app" {
  source = "./modules/dummy-payment-app"

  namespace   = var.create_namespace ? kubernetes_namespace.saleor[0].metadata[0].name : var.namespace
  environment = var.environment
  enabled     = var.dummy_payment_app_enabled

}
