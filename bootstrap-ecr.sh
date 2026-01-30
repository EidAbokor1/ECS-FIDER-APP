#!/bin/bash

set -e 

echo "Docker Image Bootstrap Script"
echo ""

AWS_REGION="eu-west-2"
ECR_REPO_NAME="fider-app"
IMAGE_NAME="fider"

echo "Getting AWS account ID..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Account ID: $AWS_ACCOUNT_ID"

ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_REPO="${ECR_URL}/${ECR_REPO_NAME}"

echo "ECR Repository: $ECR_REPO"

echo "Checking if ECR repository exists"
if aws ecr describe-repositories --repository-names $ECR_REPO_NAME --region $AWS_REGION &>/dev/null; then
    echo "ECR repository exists"
else
    echo "ECR repository doesn't exist"
    echo "Creating ECR repository"
    aws ecr create-repository \
        --repository-name $ECR_REPO_NAME \
        --region $AWS_REGION \
        --image-scanning-configuration scanOnPush=true
    echo "ECR repository created"
fi

echo "Logging in to ECR"
aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin $ECR_URL
echo "Logged in to ECR"

echo "Building Docker image"
docker build --platform linux/amd64 -t $IMAGE_NAME:latest .
echo "Image built"

echo "Tagging image"
docker tag $IMAGE_NAME:latest $ECR_REPO:latest
docker tag $IMAGE_NAME:latest $ECR_REPO:v1
echo "Image tagged"

echo "Pushing to ECR"
docker push $ECR_REPO:latest
docker push $ECR_REPO:v1
echo "Images pushed to ECR"

echo ""
echo "Bootstrap complete"
echo ""
echo "ECR Repository: $ECR_REPO"
echo "Image Tags:"
echo "  - $ECR_REPO:latest"
echo "  - $ECR_REPO:v1"
echo ""
echo "Update your terraform.tfvars with"
echo "container_image = \"$ECR_REPO:latest\""
