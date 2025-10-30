FROM node:20-alpine AS builder

ARG GIT_REF=main
ARG REPOSITORY_URL=https://github.com/saleor/dummy-payment-app.git

WORKDIR /app

ENV APP_API_BASE_URL=__APP_API_BASE_URL__
ENV SALEOR_API_URL=__SALEOR_API_URL__

RUN apk add --no-cache git

RUN git clone ${REPOSITORY_URL} . && \
    git checkout ${GIT_REF}

RUN npm install --global corepack@latest && \
    corepack enable pnpm

RUN pnpm install --frozen-lockfile

RUN pnpm build

FROM node:20-alpine AS runtime

WORKDIR /app

RUN apk add --no-cache sed && \
    npm install --global corepack@latest && \
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

EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/runtime-env.sh"]
CMD ["pnpm", "start"]
