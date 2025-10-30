#!/usr/bin/env bash

set -euo pipefail

# For saleor platform : 3.21
GIT_REF="${GIT_REF:-3481bbb0e44e85aff083cace1421536c09e7bb9e}"
IMG_VERSION="${IMG_VERSION:-3.21}"
IMG_REGISTRY="${IMG_REGISTRY:-ghcr.io/sgonzalezoyuela/saleor-storefront}"

IMAGE_TAG="${IMG_REGISTRY}:${IMG_VERSION}"

REPOSITORY_URL="${REPOSITORY_URL:-https://github.com/saleor/storefront.git}"

BUILD_TIME_SALEOR_API_URL="${BUILD_TIME_SALEOR_API_URL:-https://storefront1.saleor.cloud/graphql/}"

echo "Building Saleor Storefront Docker Image"
echo "========================================"
echo "Registry:              ${IMG_REGISTRY}"
echo "Version:               ${IMG_VERSION}"
echo "Git Ref:               ${GIT_REF}"
echo "Repository:            ${REPOSITORY_URL}"
echo "Build-time API URL:    ${BUILD_TIME_SALEOR_API_URL}"
echo "Full Image Tag:        ${IMAGE_TAG}"
echo ""
echo "NOTE: GraphQL code generation requires a real API endpoint during build."
echo "      The build-time API URL is used to fetch the GraphQL schema."
echo "      At runtime, you can override this with NEXT_PUBLIC_SALEOR_API_URL"
echo "      to point to a different environment."
echo ""

docker build \
  --build-arg GIT_REF="${GIT_REF}" \
  --build-arg REPOSITORY_URL="${REPOSITORY_URL}" \
  --build-arg BUILD_TIME_SALEOR_API_URL="${BUILD_TIME_SALEOR_API_URL}" \
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
echo "    -e NEXT_PUBLIC_SALEOR_API_URL=http://localhost:8000/graphql/ \\"
echo "    -e NEXT_PUBLIC_STOREFRONT_URL=http://localhost:3000 \\"
echo "    ${IMAGE_TAG}"
