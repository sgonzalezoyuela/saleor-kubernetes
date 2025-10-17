# Quick Start

## Validate

Run `./tf/tools/validate.sh` and make sure your environment meets the requirements.

## Deploy GKE (local access)

Modify `/etc/hosts/` and add `127.0.0.1 saleor-api saleor-api.saleor-demo.svc.cluster.local`.

Access the `tf` folder and run:

```sh
terraform apply -var-file=./envs/gke-local.tfvars
```

wait for terraform to complete, then enable port forwarding:

```sh
./tools/pf.sh saleor-demo
```

Open your brrowser and access
* `http://localhost:3000` : for storefront
* `http://localhost:9000`: for dashboard (admin@example.com/admin)
* `http://localhost:3001`: for payment app


## Deploly GKE (public access)

Access the `tf` folder and run:

```sh
terraform apply -var-file=./envs/gke-public.tfvars
```

Use `tools/show-urls.sh` after deployment to get public URLs for resources
