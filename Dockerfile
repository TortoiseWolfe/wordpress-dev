FROM node:20-alpine

WORKDIR /app

# Copy the entire frontend
COPY nextjs-frontend/ ./

# Check the next.config.js content
RUN cat next.config.js

# Install dependencies (without permissions issues)
RUN npm install

# Attempt to build with verbose output
RUN npm run build || echo "Build failed"

# Set environment variables
ENV NODE_ENV=development
ENV HOST=0.0.0.0
ENV PORT=3000

# Use development mode for now to get things working
CMD ["npm", "run", "dev"]