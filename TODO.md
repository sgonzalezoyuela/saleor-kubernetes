# Pending

## Use images

Currently we checkout projects from github and build the application before starting it (storefront and payment). We could create docker images to improve performance and reduce resources.  At the moment, compiled images produce a Typescript error.

## Use specific commits

Since we are checking out applications, and no branches or tags are available in saleor **storefront** and **dummy payment app**, we could checkout a specific commit
