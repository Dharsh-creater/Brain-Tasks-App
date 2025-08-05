#!/bin/bash

echo "Logging in to Amazon ECR..."
aws --version
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 719737572889.dkr.ecr.us-east-1.amazonaws.com

echo "Building the Docker image..."
docker build -t brain-tasks-app:latest .
docker tag brain-tasks-app:latest 719737572889.dkr.ecr.us-east-1.amazonaws.com/brain-tasks-app:latest

echo "Pushing the Docker images..."
docker push 719737572889.dkr.ecr.us-east-1.amazonaws.com/brain-tasks-app:latest

echo "Writing image definitions file..."
printf '[{"name":"brain-tasks-app","imageUri":"719737572889.dkr.ecr.us-east-1.amazonaws.com/brain-tasks-app:latest"}]' > imagedefinitions.json

echo "Build completed successfully!" 
