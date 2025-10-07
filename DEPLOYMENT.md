# Saleor Kubernetes Demo - Deployment Guide

Complete guide for deploying and testing the Saleor demo environment on Kubernetes.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment Steps](#deployment-steps)
- [Local Access & Testing](#local-access--testing)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

## Prerequisites

### Validate Prerequisites

Run the validation script:

```bash
cd tf
./tools/validate.sh
```

### Required Tools

- **kubectl** (1.19+) - Kubernetes CLI
- **Terraform** (1.0+) - Infrastructure as Code
- **KUBECONFIG** - Environment variable pointing to cluster config

### Recommended Tools

- **k9s** - Terminal UI for Kubernetes
- **stern** - Multi-pod log tailing

### Cluster Requirements

**Minimum Resources:**
- 4 CPU cores
- 8GB RAM
- 20GB storage

**Required:**
- Storage provisioner for PersistentVolumeClaims

### Verify Cluster

```bash
kubectl cluster-info

kubectl get storageclass
```

## Quick Start

NOTE: for **GKE** you must enable the **Cloud Filestore API** for storage class **standard-rwx**

```bash
cd tf

terraform init

terraform apply -var-file=envs/gke.tfvars -auto-approve

./tools/pf.sh saleor-demo
```

Add `127.0.0.1 saleor-api saleor-api.saleor-demo.svc.cluster.local` to your  `hosts` file (i.e. /etc/hosts in linux)

Open http://localhost:9000 and login with `admin@example.com` / `admin`


## Deployment Steps

### Step 1: Clean Existing Resources (Optional)

If you have an existing deployment:

```bash
kubectl delete namespace saleor-demo

./tools/clean.sh saleor-demo
./tools/clean-tf.sh
```

### Step 2: Initialize Terraform

```bash
cd tf
terraform init
```

### Step 3: Choose Configuration

#### Option A: Talos/On-Prem (with Ingress)

```bash
terraform apply -var-file=envs/talos.tfvars
```

#### Option B: GKE (without Ingress)

```bash
terraform apply -var-file=envs/gke.tfvars
```

#### Option C: Custom Configuration

```bash
cp envs/talos.tfvars my-config.tfvars
vim my-config.tfvars
terraform apply -var-file=my-config.tfvars
```

### Step 4: Monitor Deployment

```bash
kubectl get pods -n saleor-demo -w
```

Wait for all pods to reach `Running` status:

```
NAME                                   READY   STATUS    RESTARTS   AGE
saleor-api-xxx                        1/1     Running   0          5m
saleor-dashboard-xxx                  1/1     Running   0          4m
saleor-db-xxx                         1/1     Running   0          5m
saleor-jaeger-xxx                     1/1     Running   0          5m
saleor-mailpit-xxx                    1/1     Running   0          5m
saleor-redis-xxx                      1/1     Running   0          5m
saleor-storefront-xxx                 1/1     Running   0          3m
saleor-worker-xxx                     1/1     Running   0          4m
dummy-payment-app-xxx                 1/1     Running   0          3m
```

**Note:** Storefront and Payment App take 3-5 minutes to build on first startup.

### Step 5: Verify Deployment

```bash
kubectl get all,pvc -n saleor-demo
```

## Local Access & Testing

### Automated Port-Forwarding

Use the provided script to forward all services:

```bash
./tools/pf.sh saleor-demo
```

This forwards:
- **API**: localhost:8000
- **Dashboard**: localhost:9000
- **Storefront**: localhost:3000

Press `Ctrl+C` to stop all forwards.

### Manual Port-Forwarding

```bash
kubectl port-forward -n saleor-demo svc/saleor-api 8000:8000 &

kubectl port-forward -n saleor-demo svc/saleor-dashboard 9000:9000 &

kubectl port-forward -n saleor-demo svc/saleor-storefront 3000:3000 &

kubectl port-forward -n saleor-demo svc/dummy-payment-app 3001:3000 &

kubectl port-forward -n saleor-demo svc/saleor-jaeger 16686:16686 &

kubectl port-forward -n saleor-demo svc/saleor-mailpit 8025:8025 &

jobs
```

Stop all forwards:

```bash
killall kubectl
```

### Configure /etc/hosts (Optional)

For hostname resolution:

**Linux/macOS:**

```bash
sudo tee -a /etc/hosts <<EOF
127.0.0.1 saleor-api saleor-api.saleor-demo.svc.cluster.local
EOF
```

**Windows:**

Edit `C:\Windows\System32\drivers\etc\hosts` as Administrator:

```
127.0.0.1 saleor-api saleor-api.saleor-demo.svc.cluster.local
```

### Testing the Demo

#### 1. Access Dashboard

Open http://localhost:9000

**Login:**
- Email: `admin@example.com`
- Password: `admin`

**Try:**
- Browse products
- View orders
- Manage customers
- Configure shipping and payment

#### 2. Access Storefront

Open http://localhost:3000

**Try:**
- Browse product catalog
- Add items to cart
- Go through checkout process
- Create customer account

#### 3. Test API with GraphQL

Open http://localhost:8000/graphql/

**Example Query - List Products:**

```graphql
query {
  products(first: 10) {
    edges {
      node {
        id
        name
        slug
        description
      }
    }
  }
}
```

**Example Query - Get Categories:**

```graphql
query {
  categories(first: 10) {
    edges {
      node {
        name
        products(first: 5) {
          edges {
            node {
              name
              pricing {
                priceRange {
                  start {
                    gross {
                      amount
                      currency
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

**Example Mutation - Create Product:**

```graphql
mutation {
  productCreate(input: {
    name: "Test Product"
    slug: "test-product"
    productType: "UHJvZHVjdFR5cGU6MQ=="
  }) {
    product {
      id
      name
    }
    errors {
      field
      message
    }
  }
}
```

#### 4. View Distributed Traces

Open http://localhost:16686

**Try:**
- Search for `saleor-api` service
- View request traces
- Analyze performance
- Debug issues

#### 5. View Test Emails

Open http://localhost:8025

**Try:**
- Make a storefront order
- Reset password in dashboard
- View captured emails
- Test email templates

#### 6. Test Payment App

Open http://localhost:3001

**Try:**
- Configure in Dashboard under Apps
- Test payment flow in storefront
- View payment webhooks

### GraphQL API Testing with curl

```bash
curl -X POST http://localhost:8000/graphql/ \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ products(first: 5) { edges { node { name slug } } } }"
  }'
```

### Testing Email Flow

```bash
# Make an order in the storefront
# Then check Mailpit
open http://localhost:8025
```

## Customization

### Storage Configuration

#### For GKE

```hcl
# envs/gke.tfvars
create_storage_class = false
storage_class_name   = "standard-rwx"

db_storage_size    = "10Gi"
media_storage_size = "20Gi"
redis_storage_size = "2Gi"
```

#### For On-Prem/Talos

```hcl
# envs/talos.tfvars
create_storage_class = true
storage_class_name   = "saleor-storage"
storage_provisioner  = "rancher.io/local-path"

media_storage_access_mode = "ReadWriteOnce"
```

### Enable/Disable Components

```hcl
storefront_enabled = true   # Set to false to disable
dummy_payment_app_enabled = true
```

### Change Saleor Version

```hcl
saleor_image_tag = "3.20"   # Use different version
dashboard_image_tag = "3.20"
```

### Configure Ingress

```hcl
ingress_enabled     = true
ingress_class       = "nginx"
ingress_tls_enabled = true
ingress_cert_issuer = "letsencrypt-staging"

api_host        = "api.saleor.example.com"
dashboard_host  = "dashboard.saleor.example.com"
storefront_host = "storefront.saleor.example.com"
```

**Note:** Requires ingress controller and DNS configuration.

### Resource Limits

```hcl
storefront_memory_limit = "4Gi"
storefront_cpu_limit    = "4000m"
```

## Troubleshooting

### Quick Diagnostics

```bash
kubectl get all -n saleor-demo

kubectl get events -n saleor-demo --sort-by='.lastTimestamp'

kubectl top pod -n saleor-demo
```

### Common Issues

#### Storefront Build Fails

**Symptoms:**
- Pod in CrashLoopBackOff
- Logs show npm errors

**Check logs:**

```bash
kubectl logs -n saleor-demo deployment/saleor-storefront
```

**Solutions:**
1. Wait - first build takes 3-5 minutes
2. Check internet connectivity
3. Increase resources in tfvars:

```hcl
storefront_memory_limit = "4Gi"
storefront_cpu_limit = "4000m"
```

#### API Migrations Fail

**Check migration logs:**

```bash
kubectl logs -n saleor-demo deployment/saleor-api -c migrate
```

**Check database:**

```bash
kubectl get pod -n saleor-demo -l app=saleor-db

kubectl logs -n saleor-demo deployment/saleor-db
```

#### PVC Pending

**Check PVC status:**

```bash
kubectl get pvc -n saleor-demo

kubectl describe pvc saleor-db-pvc -n saleor-demo
```

**Solutions:**
1. Verify StorageClass exists: `kubectl get storageclass`
2. Set correct storage_class_name in tfvars
3. For local clusters, use local-path provisioner

#### Port-Forward Connection Refused

**Symptoms:**
- `error: unable to forward port because pod is not running`

**Solutions:**

```bash
kubectl get pods -n saleor-demo

kubectl logs -n saleor-demo <pod-name> --tail=50

kubectl port-forward -n saleor-demo deployment/saleor-api 8000:8000
```

### Useful Debugging Commands

```bash
kubectl describe pod <pod-name> -n saleor-demo

kubectl logs -n saleor-demo deployment/saleor-api --timestamps

kubectl logs -n saleor-demo deployment/saleor-api -f

kubectl logs -n saleor-demo deployment/saleor-api --previous

kubectl exec -it -n saleor-demo deployment/saleor-api -- /bin/bash

kubectl top pod -n saleor-demo
kubectl top node
```

### View All Logs

```bash
kubectl logs -n saleor-demo deployment/saleor-api
kubectl logs -n saleor-demo deployment/saleor-worker
kubectl logs -n saleor-demo deployment/saleor-storefront
kubectl logs -n saleor-demo deployment/saleor-dashboard
kubectl logs -n saleor-demo deployment/saleor-db
kubectl logs -n saleor-demo deployment/dummy-payment-app
```

### Check Init Containers

```bash
kubectl logs -n saleor-demo deployment/saleor-api -c migrate

kubectl logs -n saleor-demo deployment/saleor-api -c populatedb

kubectl logs -n saleor-demo deployment/saleor-worker -c wait-for-api
```

## Update Configuration

```bash
vim envs/my-config.tfvars

terraform plan -var-file=envs/my-config.tfvars

terraform apply -var-file=envs/my-config.tfvars
```

## Cleanup

### Destroy with Terraform

```bash
terraform destroy -var-file=envs/talos.tfvars

terraform destroy -var-file=envs/talos.tfvars -auto-approve
```

### Manual Cleanup

```bash
kubectl delete namespace saleor-demo

rm -rf .terraform terraform.tfstate*
```

### Using Cleanup Scripts

```bash
./tools/clean.sh saleor-demo

./tools/clean-tf.sh
```

## Demo Scenarios

### Scenario 1: E-commerce Flow

1. **Customer Journey:**
   - Open storefront: http://localhost:3000
   - Browse products
   - Add to cart
   - Checkout (use dummy payment)

2. **Admin View:**
   - Open dashboard: http://localhost:9000
   - View new order
   - Process fulfillment
   - Check inventory

3. **Email Verification:**
   - Open Mailpit: http://localhost:8025
   - View order confirmation email

4. **Payment App:**
   - Open Mailpit: http://localhost:3001
   - View order confirmation email

### Scenario 2: API Development

1. **Explore GraphQL:**
   - Open http://localhost:8000/graphql/
   - Use GraphQL Playground
   - Run sample queries

2. **Create Custom Queries:**
   - Query products with filters
   - Search customers
   - View order history

3. **Trace Requests:**
   - Open Jaeger: http://localhost:16686
   - View API traces
   - Analyze performance

### Scenario 3: Multi-Channel Commerce

1. **Create Channel:**
   - Dashboard → Channels
   - Add new sales channel

2. **Configure Products:**
   - Assign products to channels
   - Set channel-specific pricing

3. **Test in Storefront:**
   - Switch between channels
   - Verify pricing differences

## Development Workflow

### Making Code Changes

For API/Worker changes:

```bash
kubectl rollout restart deployment/saleor-api -n saleor-demo
kubectl rollout restart deployment/saleor-worker -n saleor-demo
```

For Storefront changes:

```bash
kubectl delete pod -n saleor-demo -l app=saleor-storefront
```

### Running Database Migrations

```bash
kubectl exec -it -n saleor-demo deployment/saleor-api -- python3 manage.py migrate
```

### Creating Django Superuser

```bash
kubectl exec -it -n saleor-demo deployment/saleor-api -- python3 manage.py createsuperuser
```

### Accessing Database

```bash
kubectl exec -it -n saleor-demo deployment/saleor-db -- psql -U saleor

\dt
SELECT * FROM product_product;
\q
```

### Accessing Redis

```bash
kubectl exec -it -n saleor-demo deployment/saleor-redis -- redis-cli

KEYS *
GET <key>
exit
```

## Environment-Specific Notes

### Google Kubernetes Engine (GKE)

```bash
terraform apply -var-file=envs/gke.tfvars
```

- Uses standard-rwx StorageClass
- API service is LoadBalancer type
- No ingress by default

### Talos Linux / On-Prem

```bash
terraform apply -var-file=envs/talos.tfvars
```

- Creates local-path StorageClass
- Enables ingress with TLS
- Uses nginx ingress controller

### Minimal Resources

```bash
terraform apply -var-file=envs/talos-minimal.tfvars
```

- Reduced resource limits
- For smaller clusters
- May have slower performance

## Tips & Tricks

### Monitor Everything

```bash
watch kubectl get all,pvc -n saleor-demo
```

### Follow All Logs

Using stern (if installed):

```bash
stern -n saleor-demo .
```

### Quick Reset

```bash
kubectl delete pod -n saleor-demo --all
```

Kubernetes will recreate all pods.

### Access Services from Pod

```bash
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -n saleor-demo -- sh

curl http://saleor-api:8000/graphql/
exit
```

## Next Steps

- Explore Saleor Dashboard features
- Test payment integrations
- Configure shipping methods
- Customize product catalog
- Try multi-currency support
- Set up webhooks
- Integrate with external services

## Resources

- **Saleor Documentation**: https://docs.saleor.io/
- **GraphQL API Reference**: https://docs.saleor.io/docs/3.x/api-reference
- **Saleor GitHub**: https://github.com/saleor/saleor
- **Community Discord**: https://discord.gg/saleor

## Support

For issues:
1. Check logs with `kubectl logs`
2. Review events with `kubectl get events`
3. Consult Saleor documentation
4. Ask in Saleor Discord/Forum
