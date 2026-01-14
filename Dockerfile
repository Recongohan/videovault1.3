# --- Stage 1: Build ---
FROM node:20-alpine AS builder
WORKDIR /app
# 1. Install dependencies (Cached layer)
COPY package.json package-lock.json ./
RUN npm ci
# 2. Copy source and build (This creates the /app/dist we saw)
COPY . .
RUN npm run build
# 3. Prune dev dependencies to keep the image slim
RUN npm prune --production

# --- Stage 2: Runner ---
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=5000

# Copy the items we verified with your 'ls' command
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 5000
CMD ["node", "dist/index.cjs"]