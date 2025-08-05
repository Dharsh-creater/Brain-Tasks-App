#!/bin/bash

# Deploy to EKS Script
echo "🚀 Starting EKS deployment..."

# Set variables
ACCOUNT_ID="719737572889"
REGION="us-east-1"
ECR_REPO="brain-tasks-app"
IMAGE_TAG="latest"
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO}"

# Login to ECR
echo "📦 Logging in to ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URI

# Build and push new image
echo "🔨 Building and pushing Docker image..."
docker build -t $ECR_REPO:$IMAGE_TAG .
docker tag $ECR_REPO:$IMAGE_TAG $ECR_URI:$IMAGE_TAG
docker push $ECR_URI:$IMAGE_TAG

# Update Kubernetes deployment
echo "⚙️ Updating Kubernetes deployment..."
kubectl set image deployment/brain-tasks-app brain-tasks-app=$ECR_URI:$IMAGE_TAG -n brain-tasks

# Wait for rollout
echo "⏳ Waiting for deployment to complete..."
kubectl rollout status deployment/brain-tasks-app -n brain-tasks

# Check status
echo "✅ Deployment completed!"
echo "📊 Checking deployment status..."
kubectl get pods -n brain-tasks
kubectl get svc -n brain-tasks

echo "🎉 Deployment successful!" 
