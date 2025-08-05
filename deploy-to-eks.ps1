# Deploy to EKS Script (PowerShell)
Write-Host "🚀 Starting EKS deployment..." -ForegroundColor Green

# Set variables
$ACCOUNT_ID = "719737572889"
$REGION = "us-east-1"
$ECR_REPO = "brain-tasks-app"
$IMAGE_TAG = "latest"
$ECR_URI = "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$ECR_REPO"

# Login to ECR
Write-Host "📦 Logging in to ECR..." -ForegroundColor Yellow
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URI

# Build and push new image
Write-Host "🔨 Building and pushing Docker image..." -ForegroundColor Yellow
docker build -t $ECR_REPO`:$IMAGE_TAG .
docker tag $ECR_REPO`:$IMAGE_TAG $ECR_URI`:$IMAGE_TAG
docker push $ECR_URI`:$IMAGE_TAG

# Update Kubernetes deployment
Write-Host "⚙️ Updating Kubernetes deployment..." -ForegroundColor Yellow
kubectl set image deployment/brain-tasks-app brain-tasks-app=$ECR_URI`:$IMAGE_TAG -n brain-tasks

# Wait for rollout
Write-Host "⏳ Waiting for deployment to complete..." -ForegroundColor Yellow
kubectl rollout status deployment/brain-tasks-app -n brain-tasks

# Check status
Write-Host "✅ Deployment completed!" -ForegroundColor Green
Write-Host "📊 Checking deployment status..." -ForegroundColor Yellow
kubectl get pods -n brain-tasks
kubectl get svc -n brain-tasks

Write-Host "🎉 Deployment successful!" -ForegroundColor Green 