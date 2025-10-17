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
      }
    )
  }
}

module "saleor_platform" {
  source = "./modules/saleor-platform"

  namespace           = var.create_namespace ? kubernetes_namespace.saleor[0].metadata[0].name : var.namespace
  environment         = var.environment
  saleor_image_tag    = var.saleor_image_tag
  dashboard_image_tag = var.dashboard_image_tag

  # Storage configuration
  create_storage_class        = var.create_storage_class
  storage_class_name          = var.storage_class_name
  storage_provisioner         = var.storage_provisioner
  storage_reclaim_policy      = var.storage_reclaim_policy
  storage_volume_binding_mode = var.storage_volume_binding_mode
  storage_allow_expansion     = var.storage_allow_expansion
  storage_parameters          = var.storage_parameters
  media_storage_access_modes  = var.media_storage_access_modes

  api_host = var.api_host
  api_port = var.api_port

  # Public access
  public_access = var.public_access

}

module "saleor_storefront" {
  source = "./modules/saleor-storefront"

  namespace   = var.create_namespace ? kubernetes_namespace.saleor[0].metadata[0].name : var.namespace
  environment = var.environment

  # Storefront configuration
  image          = "node:20-alpine"
  saleor_api_url = "${module.saleor_platform.api_url}/graphql/"
  storefront_url = var.storefront_url
  env_vars       = var.storefront_env_vars

  # API service reference
  api_service_name = module.saleor_platform.api_service_name

  # Public access
  public_access = var.public_access
}

module "dummy_payement_app" {
  source = "./modules/dummy-payment-app"

  namespace   = var.create_namespace ? kubernetes_namespace.saleor[0].metadata[0].name : var.namespace
  environment = var.environment
  enabled     = var.dummy_payment_app_enabled

  # Public access
  public_access = var.public_access

  # API URL
  saleor_api_url = module.saleor_platform.api_url
}
