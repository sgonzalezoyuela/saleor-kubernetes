FROM node:20-alpine AS builder

ARG GIT_REF=main
ARG REPOSITORY_URL=https://github.com/saleor/storefront.git
ARG BUILD_TIME_SALEOR_API_URL=https://storefront1.saleor.cloud/graphql/
ARG BUILD_TIME_STOREFRONT_URL=http://localhost:3000

WORKDIR /app

RUN apk add --no-cache git

RUN git clone ${REPOSITORY_URL} . && \
    git checkout ${GIT_REF}

RUN echo "NEXT_PUBLIC_SALEOR_API_URL=${BUILD_TIME_SALEOR_API_URL}" > .env && \
    echo "NEXT_PUBLIC_STOREFRONT_URL=${BUILD_TIME_STOREFRONT_URL}" >> .env && \
    echo "SALEOR_APP_TOKEN=" >> .env

RUN corepack enable pnpm && \
    pnpm install --frozen-lockfile

RUN pnpm build

FROM node:20-alpine AS runtime

ARG BUILD_TIME_SALEOR_API_URL=https://storefront1.saleor.cloud/graphql/
ARG BUILD_TIME_STOREFRONT_URL=http://localhost:3000

WORKDIR /app

RUN apk add --no-cache sed && \
    corepack enable pnpm

COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=builder /app/next.config.js ./next.config.js
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

COPY runtime-env.sh /usr/local/bin/runtime-env.sh
RUN chmod +x /usr/local/bin/runtime-env.sh

ENV NODE_ENV=production
ENV PORT=3000
ENV BUILD_TIME_SALEOR_API_URL=${BUILD_TIME_SALEOR_API_URL}
ENV BUILD_TIME_STOREFRONT_URL=${BUILD_TIME_STOREFRONT_URL}

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/runtime-env.sh"]
CMD ["pnpm", "start"]
