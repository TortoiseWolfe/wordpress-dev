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

# Debug: Check next.config.js content
RUN echo "Next.js config file content:" && cat next.config.js

# Build the application with verbose output
ENV NEXT_TELEMETRY_DISABLED 1
RUN npm run build

# Debug: Check if build outputs were created
RUN echo "Listing .next directory:" && ls -la .next/ || echo "No .next directory found"
RUN echo "Checking for standalone directory:" && ls -la .next/standalone/ || echo "No standalone directory found"

# Stage 3: Runner
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

# Create a non-root user and group for better security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Ensure proper permissions
RUN mkdir -p /app/.next && chown -R nextjs:nodejs /app

# Copy only necessary files from the builder stage
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./package.json

# Set up Next.js output for standalone mode
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./ || echo "Failed to copy standalone directory"
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static || echo "Failed to copy static directory"

# Switch to non-root user
USER nextjs

# Expose the port that Next.js listens on
EXPOSE 3000

# Set proper host and port for container networking
ENV HOST 0.0.0.0
ENV PORT 3000

# Command to run diagnostic check
CMD ["ls", "-la"]