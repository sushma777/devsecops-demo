# Use node image as base for building application
FROM node:20-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy all source files
COPY . .

# Build the application (if necessary)
RUN npm run build

# Use nginx image as base for serving the application
FROM nginx:alpine

# Install necessary packages
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    libexpat=2.7.0-r0 \
    libxml2=2.13.4-r5 \
    libxslt=1.1.42-r2

# Create a non-root user for running nginx, but only if they don't already exist
RUN addgroup -S nginx || true && adduser -S -G nginx nginx || true

# Copy the built application from the build stage (use dist instead of build for Vite)
COPY --from=build /app/dist /usr/share/nginx/html

# Expose the necessary port
EXPOSE 80

# Run nginx as the non-root user
USER nginx

# Start nginx server
CMD ["nginx", "-g", "daemon off;"]
