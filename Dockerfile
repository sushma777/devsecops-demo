# Build stage
FROM node:20-alpine AS build

WORKDIR /app

# Copy package.json and package-lock.json files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Run `npm audit fix` to automatically resolve vulnerabilities
RUN npm audit fix --legacy-peer-deps

# Copy the rest of the application files
COPY . .

# Build the project
RUN npm run build

# Production stage
FROM nginx:alpine

# Upgrade Alpine packages to address vulnerabilities
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    libexpat=2.7.0-r0 \
    libxml2=2.13.4-r5 \
    libxslt=1.1.42-r2

# Create a non-root user for running nginx
RUN addgroup -S nginx && adduser -S -G nginx nginx

# Copy the built files from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Change ownership of the files to the nginx user
RUN chown -R nginx:nginx /usr/share/nginx/html

# Expose port 80 for the application
EXPOSE 80

# Switch to the non-root user
USER nginx

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
