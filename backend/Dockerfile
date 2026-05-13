FROM node:20-alpine AS base
WORKDIR /app
RUN apk add --no-cache openssl

# ── Dependencies ─────────────────────────────────────────────────────────────
FROM base AS deps
COPY package*.json ./
RUN npm ci --only=production && cp -r node_modules /prod_modules
RUN npm ci

# ── Builder ───────────────────────────────────────────────────────────────────
FROM deps AS builder
COPY . .
RUN npx prisma generate
RUN npm run build

# ── Runner ────────────────────────────────────────────────────────────────────
FROM base AS runner
ENV NODE_ENV=production

RUN addgroup -g 1001 -S nodejs && adduser -S quitly -u 1001

COPY --from=builder --chown=quitly:nodejs /app/dist ./dist
COPY --from=builder --chown=quitly:nodejs /app/prisma ./prisma
COPY --from=builder --chown=quitly:nodejs /app/package*.json ./
COPY --from=deps --chown=quitly:nodejs /prod_modules ./node_modules
# Prisma generate output lives in node_modules/.prisma — copy from builder (deps never ran generate)
COPY --from=builder --chown=quitly:nodejs /app/node_modules/.prisma ./node_modules/.prisma

USER quitly

EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:4000/health || exit 1

CMD ["sh", "-c", "npx prisma migrate deploy && node dist/server.js"]
