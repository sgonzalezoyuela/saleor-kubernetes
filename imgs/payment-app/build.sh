#!/usr/bin/env bash

set -euo pipefail
# Control payment app version
GIT_REF="${GIT_REF:-f63c209035177f62dba63839fb61927fe94f81f0}"
IMG_VERSION="${IMG_VERSION:-3.21}"
IMG_REGISTRY="${IMG_REGISTRY:-ghcr.io/sgonzalezoyuela/saleor-kubernetes/saleor-payment-app}"

IMAGE_TAG="${IMG_REGISTRY}:${IMG_VERSION}"

REPOSITORY_URL="${REPOSITORY_URL:-https://github.com/saleor/dummy-payment-app.git}"

echo "Building Saleor Payment App Docker Image"
echo "========================================="
echo "Registry:              ${IMG_REGISTRY}"
echo "Version:               ${IMG_VERSION}"
echo "Git Ref:               ${GIT_REF}"
echo "Repository:            ${REPOSITORY_URL}"
echo "Full Image Tag:        ${IMAGE_TAG}"
echo ""
echo "NOTE: This image uses RUNTIME environment variable injection."
echo "      Environment variables are set when the container starts,"
echo "      not during build. This allows one image to work in multiple"
echo "      environments."
echo ""

docker build \
  --build-arg GIT_REF="${GIT_REF}" \
  --build-arg REPOSITORY_URL="${REPOSITORY_URL}" \
  -t "${IMAGE_TAG}" \
  -f Dockerfile \
  .

echo ""
echo "✅ Build successful!"
echo "Image: ${IMAGE_TAG}"
echo ""
echo "To push to registry:"
echo "  docker push ${IMAGE_TAG}"
echo ""
echo "To run locally:"
echo "  docker run -p 3000:3000 \\"
echo "    -e APP_API_BASE_URL=http://localhost:3000 \\"
echo "    -e SALEOR_API_URL=http://localhost:8000/graphql/ \\"
echo "    -e PORT=3000 \\"
echo "    ${IMAGE_TAG}"
