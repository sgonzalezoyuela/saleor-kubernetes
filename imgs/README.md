# Docker Images for Saleor Storefront and Payment App

This directory contains Dockerfiles for pre-building the Saleor Storefront and Dummy Payment App applications. Using pre-built images significantly speeds up deployment times from 3-5 minutes to 10-30 seconds.

## Directory Structure

```
imgs/
├── storefront/
│   ├── Dockerfile
│   └── .dockerignore
├── payment-app/
│   ├── Dockerfile
│   └── .dockerignore
└── README.md
```

## Benefits of Pre-built Images

- **Fast Startup**: 10-30 seconds vs 3-5 minutes
- **Consistency**: Same image across all environments
- **Reliability**: No dependency on GitHub at deploy time
- **Security**: Images can be scanned before deployment
- **Resource Efficiency**: No build resources needed in Kubernetes
- **Runtime Configuration**: Environment variables injected at startup for multi-environment support

## Building Images Locally

### Quick Build with Scripts

Each image directory contains a `build.sh` script for easy building:

**Storefront:**
```bash
cd imgs/storefront

./build.sh

IMG_VERSION=v1.0.0 GIT_REF=v1.0.0 ./build.sh

IMG_REGISTRY=ghcr.io/myorg/storefront IMG_VERSION=latest ./build.sh
```

**Payment App:**
```bash
cd imgs/payment-app

./build.sh

IMG_VERSION=v1.0.0 GIT_REF=v1.0.0 ./build.sh

IMG_REGISTRY=ghcr.io/myorg/payment-app IMG_VERSION=latest ./build.sh
```

### Build Script Variables

**Common Variables:**

| Variable | Description | Default |
|----------|-------------|---------|
| `IMG_REGISTRY` | Container registry URL | `ghcr.io/sgonzalezoyuela/saleor-{app}` |
| `IMG_VERSION` | Image tag/version | `latest` |
| `GIT_REF` | Git branch/tag/commit | `main` |
| `REPOSITORY_URL` | Source repository | Saleor official repos |

**Build-time API URL (Storefront only):**

| Variable | Description | Default |
|----------|-------------|---------|
| `BUILD_TIME_SALEOR_API_URL` | Saleor API for GraphQL schema introspection | `https://storefront1.saleor.cloud/graphql/` |

> **Note:** The build-time API must be accessible during build and have a compatible GraphQL schema. Use any Saleor 3.x instance.

## Runtime Environment Variables

> **Important:** These images use **runtime environment variable injection** with a hybrid approach:
> - **Build time**: Uses a real API endpoint to fetch GraphQL schema (required by code generator)
> - **Runtime**: Replaces the build-time API URL with your target environment's URL

### How It Works

1. **Build Time**: 
   - Uses `BUILD_TIME_SALEOR_API_URL` (default: Saleor demo cloud) to fetch GraphQL schema
   - Code generator needs a real endpoint to introspect the schema
   - Other values use placeholders (e.g., `__NEXT_PUBLIC_STOREFRONT_URL__`)

2. **Runtime**: 
   - An entrypoint script (`runtime-env.sh`) runs before the app starts
   - Replaces build-time API URL with `NEXT_PUBLIC_SALEOR_API_URL`
   - Replaces other placeholders with runtime values

3. **Result**: 
   - Build against a compatible Saleor API (any version with compatible schema)
   - Deploy to any environment by setting runtime env vars

### Required Runtime Variables

**Storefront:**

| Variable | Description | Example |
|----------|-------------|---------|
| `NEXT_PUBLIC_SALEOR_API_URL` | Saleor API GraphQL endpoint (required) | `https://api.example.com/graphql/` |
| `NEXT_PUBLIC_STOREFRONT_URL` | Storefront public URL (required) | `https://store.example.com` |
| `SALEOR_APP_TOKEN` | Token for fetching channels (optional) | `your-token-here` |

**Payment App:**

| Variable | Description | Example |
|----------|-------------|---------|
| `APP_API_BASE_URL` | Payment app base URL | `https://payment.example.com` |
| `SALEOR_API_URL` | Saleor API endpoint | `https://api.example.com/graphql/` |

> **Note:** When deploying to Kubernetes, these are automatically set by the Terraform modules.

### Manual Docker Build

```bash
cd imgs/storefront
docker build -t saleor-storefront:latest .

cd imgs/payment-app
docker build --build-arg GIT_REF=v1.0.0 -t saleor-payment-app:v1.0.0 .
```

## Docker Build Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `GIT_REF` | Git branch, tag, or commit to checkout | `main` |
| `REPOSITORY_URL` | Git repository URL | Saleor official repos |

> **Note:** Environment-specific URLs are NOT build arguments anymore. They are injected at runtime for maximum flexibility.

## Automated Builds with GitHub Actions

The repository includes a GitHub Actions workflow (`.github/workflows/build-images.yml`) that automatically builds and pushes images to GitHub Container Registry (ghcr.io).

### Triggers

- **Push to main**: Builds and tags as `latest`
- **Pull requests**: Builds for testing (no push)
- **Manual dispatch**: Build specific git refs

### Image Tags

Images are automatically tagged with:
- `latest` - Latest build from main branch
- `main-<sha>` - Commit SHA from main branch
- `pr-<number>` - Pull request builds

### Using Pre-built Images from GitHub

```bash
docker pull ghcr.io/YOUR_ORG/saleor-kubernetes/storefront:latest
docker pull ghcr.io/YOUR_ORG/saleor-kubernetes/payment-app:latest
```

## Pushing to Custom Registry

### Docker Hub

```bash
docker tag saleor-storefront:latest your-username/saleor-storefront:latest
docker push your-username/saleor-storefront:latest
```

### GCP Artifact Registry

```bash
docker tag saleor-storefront:latest us-docker.pkg.dev/PROJECT/REPO/saleor-storefront:latest
docker push us-docker.pkg.dev/PROJECT/REPO/saleor-storefront:latest
```

### Private Registry

```bash
docker tag saleor-storefront:latest registry.example.com/saleor-storefront:latest
docker push registry.example.com/saleor-storefront:latest
```

## Using Pre-built Images in Terraform

### Default Behavior (Pre-built Images)

By default, the Terraform modules are configured to use pre-built images:

```hcl
module "saleor_platform" {
  source = "./modules/saleor-platform"
}
```

### Using Custom Pre-built Images

```hcl
module "saleor_platform" {
  source = "./modules/saleor-platform"
  
  storefront_prebuilt_image    = "ghcr.io/your-org/storefront:v1.0.0"
  payment_app_prebuilt_image   = "ghcr.io/your-org/payment-app:v1.0.0"
}
```

### Fallback to Build-from-Source

For development or when pre-built images aren't available:

```hcl
module "saleor_platform" {
  source = "./modules/saleor-platform"
  
  storefront_use_prebuilt_image   = false
  payment_app_use_prebuilt_image  = false
  storefront_git_ref              = "main"
  payment_app_git_ref             = "main"
}
```

## Multi-stage Build Details

Both Dockerfiles use multi-stage builds with runtime configuration:

### Stage 1: Builder
- Clones the repository
- Checks out specified git ref
- Installs dependencies
- **Sets placeholder environment variables** (e.g., `__NEXT_PUBLIC_SALEOR_API_URL__`)
- Builds the application with placeholders

### Stage 2: Runtime
- Minimal Node.js Alpine base
- Copies built artifacts and dependencies
- Includes `runtime-env.sh` entrypoint script
- **On container start**: Replaces placeholders with actual runtime env vars
- Smaller final image size with maximum flexibility

## Troubleshooting

### Build Fails: "fatal: couldn't find remote ref"

The specified `GIT_REF` doesn't exist. Check available branches/tags:

```bash
git ls-remote https://github.com/saleor/storefront.git
```

### Image Too Large

Multi-stage builds should keep images under 500MB. If larger:
- Check `.dockerignore` is present
- Verify only production dependencies are included
- Consider using `node:20-alpine` base

### Container Starts But App Doesn't Work

**Cause**: Environment variables not set at runtime.

**Solution**: Ensure these variables are set when running the container:

**Storefront:**
```bash
docker run -p 3000:3000 \
  -e NEXT_PUBLIC_SALEOR_API_URL=https://api.example.com/graphql/ \
  -e NEXT_PUBLIC_STOREFRONT_URL=https://store.example.com \
  ghcr.io/sgonzalezoyuela/saleor-storefront:latest
```

**Payment App:**
```bash
docker run -p 3000:3000 \
  -e APP_API_BASE_URL=https://payment.example.com \
  -e SALEOR_API_URL=https://api.example.com/graphql/ \
  ghcr.io/sgonzalezoyuela/saleor-payment-app:latest
```

These are configured by Terraform modules automatically when deployed to Kubernetes.

### Placeholder Values in Logs

If you see `__NEXT_PUBLIC_SALEOR_API_URL__` in error messages, the runtime script didn't run properly. Check:
- Container is using the correct entrypoint
- `runtime-env.sh` is executable
- Environment variables are passed to the container

## Image Versioning Strategy

### Development
- Use `latest` tag
- Rebuild frequently

### Staging
- Use branch-specific tags: `main-<sha>`
- Track with git commit

### Production
- Use semantic version tags: `v1.0.0`
- Immutable tags
- Test thoroughly before promoting

## Security Best Practices

1. **Scan Images**: Use tools like Trivy or Snyk
2. **Update Base Images**: Keep `node:20-alpine` updated
3. **No Secrets**: Never bake secrets into images
4. **Signed Images**: Consider using Docker Content Trust
5. **Private Registry**: Use private registry for production

## Resources

- [Saleor Storefront](https://github.com/saleor/storefront)
- [Dummy Payment App](https://github.com/saleor/dummy-payment-app)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
