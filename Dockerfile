# Build Stage
FROM node:20-alpine AS build
WORKDIR /app

# Install dependencies
RUN apk update && apk upgrade --no-cache
COPY package*.json ./
RUN npm ci

# Copy source code and build app
COPY . .
RUN npm run build

# Production Stage
FROM nginx:alpine

# Copy built files from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Optionally, add a custom nginx configuration file
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
