# Saleor Kubernetes Demo Deployment

Automated Terraform deployment for demonstrating and developing with the Saleor e-commerce platform on Kubernetes. This project provides a complete, ready-to-use Saleor stack including platform, storefront, dashboard, and payment application.

## Architecture Overview

This project deploys a complete Saleor development environment using Terraform and Kubernetes. All components run in a single namespace and are configured for easy local access and testing.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Kubernetes Cluster                      │
│                                                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Ingress (Optional)                        │ │
│  │         nginx/traefik with TLS support                 │ │
│  └────────────────────────────────────────────────────────┘ │
│                           │                                 │
│         ┌─────────────────┼───────────────┐                 │
│         │                 │               │                 │
│  ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐          │
│  │  Dashboard  │  │     API     │  │ Storefront  │          │
│  │   (React)   │  │  (Django)   │  │  (Next.js)  │          │
│  │   Port 9000 │  │  Port 8000  │  │  Port 3000  │          │
│  └─────────────┘  └──────┬──────┘  └──────┬──────┘          │
│                          │                │                 │
│                    ┌─────┴────────────────┘                 │
│                    │                                        │
│           ┌────────▼────────┐       ┌──────────────┐        │
│           │  Celery Worker  │       │ Payment App  │        │
│           │  (Background    │       │  (Next.js)   │        │
│           │     Tasks)      │       │  Port 3000   │        │
│           └───────┬─────────┘       └──────────────┘        │
│                   │                                         │
│    ┌──────────────┼───────────────┬──────────────┐          │
│    │              │               │              │          │
│ ┌──▼─────┐    ┌───▼────┐      ┌───▼────┐    ┌────▼────┐     │
│ │Postgres│    │ Redis  │      │ Jaeger │    │ Mailpit │     │
│ │Database│    │ Cache/ │      │Tracing │    │  SMTP   │     │
│ │  5432  │    │ Broker │      │ 16686  │    │  8025   │     │
│ └────────┘    └────────┘      └────────┘    └─────────┘     │
│     │             │                                         │
│  ┌──▼─────────────▼───┐                                     │
│  │ Persistent Storage │                                     │
│  │ (PVCs: db, media,  │                                     │
│  │      redis)        │                                     │
│  └────────────────────┘                                     │
└─────────────────────────────────────────────────────────────┘
```

### Components

#### Frontend Applications

**Dashboard (port 9000)**
- React-based admin interface for managing products, orders, and customers
- Connects to API GraphQL endpoint
- Default credentials: `admin@example.com` / `admin`

**Storefront (port 3000)**
- Next.js customer-facing e-commerce application
- Built from source on container startup
- Demonstrates product browsing, cart, and checkout flows

**Dummy Payment App (port 3000)**
- Next.js payment integration demo
- Shows how to integrate payment providers with Saleor

#### Backend Services

**API (port 8000)**
- Django-based GraphQL API
- Automatically runs migrations and populates demo data on startup
- Includes sample products, categories, and admin user

**Worker**
- Celery worker for background tasks
- Processes orders, sends emails, generates thumbnails
- Uses Redis as message broker

#### Data Layer

**PostgreSQL (port 5432)**
- Main database for Saleor
- Persistent storage for products, orders, customers

**Redis (port 6379)**
- Cache for API responses
- Celery task queue broker

#### Development Tools

**Jaeger (port 16686)**
- Distributed tracing UI
- Monitor and debug API requests across services

**Mailpit (port 8025)**
- SMTP server for development
- Web UI to view all emails sent by Saleor

## Prerequisites

- Kubernetes cluster (1.19+)
- Terraform (1.0+)
- kubectl configured with cluster access
- Minimum resources: 8 CPU cores, 16GB RAM

## Quick Start

```bash
cd tf

terraform init

terraform apply -var-file=envs/talos.tfvars

./tools/pf.sh saleor-demo
```

NOTE: Add `127.0.0.1 saleor-api saleor-api.saleor-demo.svc.cluster.local` to your  `hosts` file (i.e. /etc/hosts in linux)

Then open:
- **Dashboard**: http://localhost:9000
- **Storefront**: http://localhost:3000
- **API GraphQL**: http://localhost:8000/graphql/
- **Jaeger**: http://localhost:16686
- **Mailpit**: http://localhost:8025

Default admin credentials: `admin@example.com` / `admin`

## Directory Structure

```
imgs/                               # Docker image builds
├── storefront/                     # Storefront Dockerfile
│   ├── Dockerfile
│   └── .dockerignore
├── payment-app/                    # Payment app Dockerfile
│   ├── Dockerfile
│   └── .dockerignore
└── README.md                       # Build instructions
tf/
├── main.tf                          # Root module orchestration
├── variables.tf                     # Input variables
├── outputs.tf                       # Exposed outputs
├── versions.tf                      # Provider versions
├── envs/                           # Environment configs
│   ├── gke.tfvars                  # Google Kubernetes Engine
│   ├── talos.tfvars                # Talos Linux
│   └── talos-minimal.tfvars        # Minimal resources
├── modules/
│   ├── saleor-platform/            # Core Saleor deployment
│   │   ├── api.tf                  # API deployment & service
│   │   ├── worker.tf               # Celery worker
│   │   ├── dashboard.tf            # Dashboard UI
│   │   ├── database.tf             # PostgreSQL
│   │   ├── redis.tf                # Redis cache
│   │   ├── storage.tf              # Persistent volumes
│   │   ├── storage-class.tf        # Storage provisioner
│   │   ├── configmaps.tf           # Configuration
│   │   ├── ingress.tf              # External access
│   │   ├── monitoring.tf           # Jaeger tracing
│   │   ├── mail.tf                 # Mailpit SMTP
│   │   └── locals.tf               # Computed values
│   ├── saleor-storefront/          # Customer store
│   │   └── main.tf
│   └── dummy-payment-app/          # Payment demo
│       └── main.tf
└── tools/                          # Utility scripts
    ├── pf.sh                       # Port-forwarding helper
    ├── clean.sh                    # Resource cleanup
    ├── clean-tf.sh                 # Terraform cleanup
    └── validate.sh                 # Check prerequisites
```

## Configuration

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `namespace` | Kubernetes namespace | `saleor` |
| `environment` | Environment label | `dev` |
| `saleor_image_tag` | Saleor version | `3.21` |
| `storefront_enabled` | Deploy storefront | `true` |
| `dummy_payment_app_enabled` | Deploy payment app | `true` |
| `ingress_enabled` | Enable external access | `false` |

### Storage Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `create_storage_class` | Create StorageClass | `false` |
| `storage_class_name` | StorageClass name | `saleor-storage` |
| `db_storage_size` | Database size | `1Gi` |
| `media_storage_size` | Media files size | `1Gi` |
| `redis_storage_size` | Redis size | `1Gi` |

### Example Configurations

See `envs/` directory for environment-specific examples:
- `gke.tfvars` - Google Kubernetes Engine
- `talos.tfvars` - Talos Linux with ingress
- `talos-minimal.tfvars` - Minimal resources

## Accessing the Application

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions on:
- Port-forwarding setup
- Configuring /etc/hosts
- Testing each component
- GraphQL API examples

## Module Architecture

### saleor-platform

The main module deploys all core Saleor components:
- Creates namespace with labels
- Configures storage (StorageClass, PVCs)
- Deploys database and Redis
- Deploys API with init containers for migrations
- Deploys worker for background tasks
- Deploys dashboard UI
- Configures monitoring (Jaeger) and mail (Mailpit)
- Optionally creates ingress for external access

### saleor-storefront

Deploys the customer-facing Next.js storefront:
- **Default**: Uses pre-built Docker image (fast deployment)
- **Alternative**: Can build from GitHub source (set `use_prebuilt_image = false`)
- Connects to API GraphQL endpoint
- Can be disabled via `storefront_enabled = false`

### dummy-payment-app

Deploys a demo payment application:
- **Default**: Uses pre-built Docker image (fast deployment)
- **Alternative**: Can build from GitHub source (set `use_prebuilt_image = false`)
- Shows payment integration patterns
- Connects to Saleor API
- Can be disabled via `dummy_payment_app_enabled = false`

## Key Design Features

### Automatic Initialization

**API Init Containers:**
1. **migrate** - Runs Django migrations
2. **populatedb** - Creates sample data and admin user

**Worker Init Container:**
- Waits for API to be ready before starting

**Storefront Init:**
- Waits for API availability
- Clones and builds from source

### Pod Affinity

API and Worker pods prefer co-location for:
- Shared media storage access
- Reduced network latency
- Better cache locality

### Pre-built Images (Default)

Storefront and Payment App use pre-built Docker images by default:
- **Fast startup**: 10-30 seconds vs 3-5 minutes
- **Consistent deployments**: Same image across all environments
- **Resource efficient**: No build resources needed in cluster
- **Reliable**: No dependency on GitHub at deploy time
- See `imgs/` directory for Dockerfiles and build instructions

**Fallback to source builds**: Set `use_prebuilt_image = false` for development or custom builds

### Service Discovery

All services use Kubernetes DNS:
- `saleor-api.saleor-demo.svc.cluster.local:8000`
- `saleor-db.saleor-demo.svc.cluster.local:5432`
- `saleor-redis.saleor-demo.svc.cluster.local:6379`

## Outputs

After deployment, Terraform provides:

```hcl
namespace              # Deployment namespace
api_service            # API service name
dashboard_service      # Dashboard service name
database_service       # PostgreSQL service name
redis_service          # Redis service name
storefront_service     # Storefront service name
ingress_endpoints      # External URLs (if enabled)
```

## Development Workflow

### Making Changes

```bash
# Edit configuration
vim envs/my-config.tfvars

# Review changes
terraform plan -var-file=envs/my-config.tfvars

# Apply changes
terraform apply -var-file=envs/my-config.tfvars
```

### Viewing Logs

```bash
# API logs
kubectl logs -n saleor-demo deployment/saleor-api -f

# Worker logs
kubectl logs -n saleor-demo deployment/saleor-worker -f

# Storefront build logs
kubectl logs -n saleor-demo deployment/saleor-storefront -f
```

### Restarting Components

```bash
# Restart API
kubectl rollout restart deployment/saleor-api -n saleor-demo

# Restart all components
kubectl rollout restart deployment -n saleor-demo
```

## Troubleshooting

### Check Pod Status

```bash
# List all pods
kubectl get pods -n saleor-demo

# Describe pod
kubectl describe pod <pod-name> -n saleor-demo

# View events
kubectl get events -n saleor-demo --sort-by='.lastTimestamp'
```

### Common Issues

**Storefront/Payment app takes long to start:**
- If using pre-built images: Should start in 10-30 seconds
- If building from source (`use_prebuilt_image = false`): First build takes 3-5 minutes
- Check logs: `kubectl logs -n saleor-demo deployment/saleor-storefront`

**Image pull errors:**
- Verify image exists: `docker pull <image-name>`
- Check GitHub Container Registry permissions if using ghcr.io
- See `imgs/README.md` for building images locally

**API migrations fail:**
- Check database is running: `kubectl get pod -n saleor-demo -l app=saleor-db`
- View migration logs: `kubectl logs -n saleor-demo deployment/saleor-api -c migrate`

**PVC pending:**
- Check StorageClass: `kubectl get storageclass`
- Describe PVC: `kubectl describe pvc -n saleor-demo`

## Cleanup

```bash
# Destroy all resources
terraform destroy -var-file=envs/talos.tfvars

# Or use cleanup scripts
./tools/clean.sh saleor-demo
./tools/clean-tf.sh
```

## Demo Scenarios

### E-commerce Demo

1. Browse products in Storefront (http://localhost:3000)
2. Add items to cart
3. Go through checkout
4. View order in Dashboard (http://localhost:9000)
5. Check order email in Mailpit (http://localhost:8025)

### API Development

1. Open GraphQL Playground (http://localhost:8000/graphql/)
2. Explore schema and run queries
3. Create products, manage inventory
4. Test mutations and subscriptions

### Tracing & Monitoring

1. Make some API requests
2. View traces in Jaeger (http://localhost:16686)
3. Analyze request flow across services
4. Debug performance issues

## Resources

- **Saleor Documentation**: https://docs.saleor.io/
- **Saleor GitHub**: https://github.com/saleor/saleor
- **GraphQL API Docs**: https://docs.saleor.io/docs/3.x/api-reference
- **Terraform Kubernetes Provider**: https://registry.terraform.io/providers/hashicorp/kubernetes/

## License

See the main Saleor project for licensing information.
