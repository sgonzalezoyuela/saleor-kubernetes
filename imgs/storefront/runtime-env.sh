#!/bin/sh

set -e

echo "Injecting runtime environment variables..."

if [ -z "$NEXT_PUBLIC_SALEOR_API_URL" ]; then
  echo "ERROR: NEXT_PUBLIC_SALEOR_API_URL must be set"
  exit 1
fi

if [ -z "$NEXT_PUBLIC_STOREFRONT_URL" ]; then
  echo "ERROR: NEXT_PUBLIC_STOREFRONT_URL must be set"
  exit 1
fi

if [ -z "$SALEOR_APP_TOKEN" ]; then
  SALEOR_APP_TOKEN=""
  echo "INFO: SALEOR_APP_TOKEN not set (optional)"
fi

BUILD_TIME_API_URL="${BUILD_TIME_SALEOR_API_URL:-https://storefront1.saleor.cloud/graphql/}"
BUILD_TIME_SF_URL="${BUILD_TIME_STOREFRONT_URL:-http://localhost:3000}"

echo "Replacing build-time values with runtime values..."
echo "  API URL:  ${BUILD_TIME_API_URL} -> ${NEXT_PUBLIC_SALEOR_API_URL}"
echo "  Store URL: ${BUILD_TIME_SF_URL} -> ${NEXT_PUBLIC_STOREFRONT_URL}"

find /app/.next \( -type d -name .git -prune \) -o -type f -name "*.js" -print0 | xargs -0 sed -i "s|${BUILD_TIME_API_URL}|${NEXT_PUBLIC_SALEOR_API_URL}|g"
find /app/.next \( -type d -name .git -prune \) -o -type f -name "*.js" -print0 | xargs -0 sed -i "s|${BUILD_TIME_SF_URL}|${NEXT_PUBLIC_STOREFRONT_URL}|g"

echo "Runtime environment variables injected successfully"
echo "NEXT_PUBLIC_SALEOR_API_URL: ${NEXT_PUBLIC_SALEOR_API_URL}"
echo "NEXT_PUBLIC_STOREFRONT_URL: ${NEXT_PUBLIC_STOREFRONT_URL}"
echo "SALEOR_APP_TOKEN: ${SALEOR_APP_TOKEN:+[SET]}"

exec "$@"
