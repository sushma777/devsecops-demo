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

# Copy the built files from the build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80 for the application
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
