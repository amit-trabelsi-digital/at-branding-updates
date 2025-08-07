# Admin Panel - Production Build for Railway
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .

# Build arguments for API URL
ARG VITE_API_URL=https://mental-coach-api.up.railway.app/api
ARG VITE_ENV=production

# Build the app
RUN npm run build

# Nginx stage
FROM nginx:alpine

# Copy built files
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Railway uses PORT env variable
ENV PORT=80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]