# Stage 1: Dependencies
FROM node:20-alpine AS deps
WORKDIR /app

# Copy package files
COPY nextjs-frontend/package.json nextjs-frontend/package-lock.json* ./

# Set correct permissions for node_modules
RUN mkdir -p /app/node_modules && chown -R node:node /app
USER node
RUN npm ci

# Stage 2: Builder
FROM node:20-alpine AS builder
WORKDIR /app

# Ensure builder has correct permissions
RUN mkdir -p /app/.next && chown -R node:node /app
USER node

# Copy dependencies from deps stage
COPY --from=deps --chown=node:node /app/node_modules ./node_modules

# Copy the entire Next.js project from the nextjs-frontend folder
COPY --chown=node:node nextjs-frontend/ ./

# Set build-time environment variables (can be overridden at build time)
ARG NEXT_PUBLIC_WORDPRESS_API_URL
ENV NEXT_PUBLIC_WORDPRESS_API_URL=${NEXT_PUBLIC_WORDPRESS_API_URL}

# Build the application
ENV NEXT_TELEMETRY_DISABLED 1
RUN npm run build

# Stage 3: Runner
FROM node:20-alpine AS runner
WORKDIR /app

# Set runtime environment variables with defaults (can be overridden at runtime)
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV HOST=0.0.0.0
ENV PORT=3000

# Create a non-root user and group for better security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Ensure proper permissions
RUN mkdir -p /app/.next && chown -R nextjs:nodejs /app

# Copy only necessary files from the builder stage
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json

# Set up Next.js output for standalone mode
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Switch to non-root user
USER nextjs

# Expose the port that Next.js listens on
EXPOSE 3000

# Start command with HOST binding to 0.0.0.0 to make it accessible
CMD ["sh", "-c", "NODE_ENV=production HOST=0.0.0.0 node server.js"]