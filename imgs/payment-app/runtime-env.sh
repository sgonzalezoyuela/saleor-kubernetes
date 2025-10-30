#!/bin/sh

set -e

echo "Injecting runtime environment variables..."

if [ -z "$APP_API_BASE_URL" ]; then
  echo "WARNING: APP_API_BASE_URL not set"
fi

if [ -z "$SALEOR_API_URL" ]; then
  echo "WARNING: SALEOR_API_URL not set"
fi

find /app/.next \( -type d -name .git -prune \) -o -type f -name "*.js" -print0 | xargs -0 sed -i "s|__APP_API_BASE_URL__|${APP_API_BASE_URL}|g"
find /app/.next \( -type d -name .git -prune \) -o -type f -name "*.js" -print0 | xargs -0 sed -i "s|__SALEOR_API_URL__|${SALEOR_API_URL}|g"

echo "Runtime environment variables injected successfully"
echo "APP_API_BASE_URL: ${APP_API_BASE_URL}"
echo "SALEOR_API_URL: ${SALEOR_API_URL}"

exec "$@"
