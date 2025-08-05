# Use nginx alpine as base image for serving static files
FROM public.ecr.aws/nginx/nginx:alpine

# Copy the built application files to nginx's default serving directory
COPY Brain-Tasks-App-main/dist/ /usr/share/nginx/html/

# Copy a custom nginx configuration to handle React routing
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 
