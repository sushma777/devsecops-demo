# Build Stage
FROM node:20-alpine AS build
WORKDIR /app

# Install dependencies (ensure latest security patches)
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache bash

# Copy package.json and package-lock.json, then install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy the rest of the application code
COPY . .

# Ensure the build script exists and run the build
RUN if [ ! -f "package.json" ]; then echo "No package.json found"; exit 1; fi
RUN if ! grep -q '"build"' package.json; then echo "No build script in package.json"; exit 1; fi
RUN npm run build

# Production Stage
FROM nginx:alpine

# Install only necessary packages (e.g., bash, curl) if needed
RUN apk update && apk add --no-cache bash curl

# Create a non-root user to run the application for better security
RUN adduser -D appuser

# Copy built files from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Set the correct user
USER appuser

# Optionally, add a custom nginx configuration file
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
