# Use the official Node.js image to build the application
FROM node:16 AS build

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

# Set the user to root to have necessary permissions for file system modification
USER root

# Install necessary packages
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    libexpat=2.7.0-r0 \
    libxml2=2.13.4-r5 \
    libxslt=1.1.42-r2

# Ensure necessary directories have appropriate permissions
RUN mkdir -p /var/cache/nginx && chmod 777 /var/cache/nginx
RUN chmod -R 777 /usr/share/nginx/html  #Ensure Nginx

# Copy the built application from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Expose the necessary port
EXPOSE 80

# Start nginx server
CMD ["nginx", "-g", "daemon off;"]
