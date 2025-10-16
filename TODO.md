# Pending

## Use images

Currently we checkout projects from github and build the application before starting it (storefront and payment). We could create docker images to improve performance and reduce resources.  At the moment, compiled images produce a Typescript error.

## Use specific commits

Since we are checking out applications, and no branches or tags are available in saleor **storefront** and **dummy payment app**, we could checkout a specific commit

## Remove Variables

Not required to run the demo , use defaults

## Expose to Internet

Daniel Goldberg
9:22 AM
```
annotations = var.public_access ? {} : {
      "networking.gke.io/load-balancer-type" = "Internal"
    }
```

For example
```
resource "kubernetes_service" "myservice" {
  metadata {
    name      = "myservice"
    namespace = kubernetes_namespace.myservice.metadata[0].name
    annotations = var.public_access ? {} : {
      "networking.gke.io/load-balancer-type" = "Internal"
    }
    labels = {
      app = "myservice"
    }
  }
```


