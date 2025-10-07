resource "kubernetes_ingress_v1" "saleor" {
  count = var.ingress_enabled ? 1 : 0
  
  metadata {
    name      = "saleor-ingress"
    namespace = var.namespace
    labels    = local.common_labels
    
    annotations = merge(
      {
        "kubernetes.io/ingress.class" = var.ingress_class
      },
      var.ingress_cert_issuer != "" ? {
        "cert-manager.io/issuer" = var.ingress_cert_issuer
      } : {}
    )
  }
  
  spec {
    dynamic "tls" {
      for_each = var.ingress_tls_enabled ? [1] : []
      content {
        hosts = [
          var.api_host,
          var.dashboard_host,
          var.jaeger_host,
          var.mailpit_host
        ]
        secret_name = var.ingress_tls_secret
      }
    }
    
    rule {
      host = var.api_host
      
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = kubernetes_service.saleor_api.metadata[0].name
              port {
                number = 8000
              }
            }
          }
        }
      }
    }
    
    rule {
      host = var.dashboard_host
      
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = kubernetes_service.saleor_dashboard.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    
    rule {
      host = var.jaeger_host
      
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = kubernetes_service.saleor_jaeger.metadata[0].name
              port {
                number = 16686
              }
            }
          }
        }
      }
    }
    
    rule {
      host = var.mailpit_host
      
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          
          backend {
            service {
              name = kubernetes_service.saleor_mailpit.metadata[0].name
              port {
                number = 8025
              }
            }
          }
        }
      }
    }
  }
}