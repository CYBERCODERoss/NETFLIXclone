# Use the official Node.js image as a builder stage
FROM node:16.17.0-alpine as builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and yarn.lock to the working directory
COPY ./package.json .
COPY ./yarn.lock .

# Install dependencies using yarn
RUN yarn install

# Copy the entire application code to the working directory
COPY . .

# Set build-time argument for TMDB API key
ARG TMDB_V3_API_KEY

# Set environment variable for TMDB API key
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}

# Set environment variable for TMDB API endpoint URL
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

# Build the application
RUN yarn build

# Start a new stage using the official Nginx image
FROM nginx:stable-alpine

# Set the working directory inside the Nginx container
WORKDIR /usr/share/nginx/html

# Remove existing content in the Nginx HTML directory
RUN rm -rf ./*

# Copy the built application from the builder stage to the Nginx HTML directory
COPY --from=builder /app/dist .

# Expose port 80 for incoming traffic
EXPOSE 80

# Specify the entrypoint command to start Nginx in the foreground
ENTRYPOINT ["nginx", "-g", "daemon off;"]
