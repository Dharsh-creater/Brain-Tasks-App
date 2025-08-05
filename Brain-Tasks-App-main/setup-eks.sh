#!/bin/bash

# EKS Setup and Deployment Script for Brain Tasks App
# This script sets up an EKS cluster and deploys the application

set -e

# Configuration
CLUSTER_NAME="brain-tasks-cluster"
REGION="us-east-1"
NAMESPACE="brain-tasks"

echo "🚀 Starting EKS setup for Brain Tasks App..."

# Check if eksctl is installed
if ! command -v eksctl &> /dev/null; then
    echo "❌ eksctl is not installed. Please install it first:"
    echo "   https://eksctl.io/introduction/installation/"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first."
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI is not configured. Please run 'aws configure' first."
    exit 1
fi

echo "🔧 Creating EKS cluster..."
eksctl create cluster -f eks-cluster-config.yaml

echo "⏳ Waiting for cluster to be ready..."
eksctl utils wait-for-cluster --name=$CLUSTER_NAME --region=$REGION

echo "🔐 Updating kubeconfig..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

echo "📋 Creating namespace..."
kubectl apply -f k8s/namespace.yaml

echo "🔑 Creating ECR secret for image pull..."
kubectl create secret docker-registry ecr-secret \
    --docker-server=719737572889.dkr.ecr.us-east-1.amazonaws.com \
    --docker-username=AWS \
    --docker-password=$(aws ecr get-login-password --region us-east-1) \
    --namespace=$NAMESPACE

echo "🚀 Deploying Brain Tasks application..."
kubectl apply -f k8s/deployment.yaml -n $NAMESPACE
kubectl apply -f k8s/service.yaml -n $NAMESPACE

echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/brain-tasks-app -n $NAMESPACE

echo "📊 Getting service information..."
kubectl get svc brain-tasks-service -n $NAMESPACE

echo "✅ Deployment complete!"
echo "🌐 Your application will be available at the LoadBalancer URL above"
echo "📋 To check deployment status: kubectl get pods -n $NAMESPACE"
echo "📋 To view logs: kubectl logs -f deployment/brain-tasks-app -n $NAMESPACE" 
