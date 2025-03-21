# Build stage
FROM node:20-alpine3.21 AS build  # Use specific version of Alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine3.21  # Use specific version of Alpine for Nginx

# Security hardening for Nginx (Example: disable SSLv3 and TLSv1)
# You can replace this with your own secure Nginx configuration file if needed.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Remove unnecessary files and only copy the build directory from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Optional: Set permissions to the Nginx folder (if needed)
RUN chown -R nginx:nginx /usr/share/nginx/html

# Expose port 80 (HTTP) and 443 (HTTPS) for secure connections
EXPOSE 80 443

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]

# Use an entrypoint to ensure the right security context (e.g., user)
USER nginx
