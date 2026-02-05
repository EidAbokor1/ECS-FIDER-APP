#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Terraform Deployment Helper"

CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

if [ "$CURRENT_BRANCH" == "dev" ]; then
    WORKSPACE="dev"
    TFVARS_FILE="terraform.dev.tfvars"
    EXPECTED_BRANCH="dev"
elif [ "$CURRENT_BRANCH" == "staging" ]; then
    WORKSPACE="staging"
    TFVARS_FILE="terraform.dev.tfvars"
    EXPECTED_BRANCH="staging"
elif [ "$CURRENT_BRANCH" == "main" ]; then
    WORKSPACE="prod"
    TFVARS_FILE="terraform.prod.tfvars"
    EXPECTED_BRANCH="main"
else
    echo -e "${RED}Error: Unknown branch '$CURRENT_BRANCH'${NC}"
    echo "Please switch to dev, staging, or main branch"
    exit 1
fi

echo "Target workspace: $WORKSPACE"
echo "Using tfvars: $TFVARS_FILE"

if [ ! -f "$TFVARS_FILE" ]; then
    echo -e "${RED}Error: $TFVARS_FILE not found${NC}"
    exit 1
fi

CURRENT_WORKSPACE=$(terraform workspace show 2>/dev/null || echo "none")
echo "Current workspace: $CURRENT_WORKSPACE"

if [ "$CURRENT_WORKSPACE" != "$WORKSPACE" ]; then
    echo -e "${YELLOW}Switching to workspace: $WORKSPACE${NC}"
    terraform workspace select $WORKSPACE 2>/dev/null || terraform workspace new $WORKSPACE
fi

CURRENT_WORKSPACE=$(terraform workspace show)
if [ "$CURRENT_WORKSPACE" != "$WORKSPACE" ]; then
    echo -e "${RED}Error: Workspace mismatch!${NC}"
    echo "Current workspace: $CURRENT_WORKSPACE"
    echo "Expected workspace: $WORKSPACE"
    exit 1
fi

echo -e "${GREEN}Branch and workspace match!${NC}"
echo ""

COMMAND=${1:-plan}

case $COMMAND in
    plan)
        echo "Running: terraform plan -var-file=$TFVARS_FILE"
        terraform plan -var-file="$TFVARS_FILE"
        ;;
    apply)
        echo "Running: terraform apply -var-file=$TFVARS_FILE"
        terraform apply -var-file="$TFVARS_FILE"
        ;;
    destroy)
        echo -e "${RED}Running: terraform destroy -var-file=$TFVARS_FILE${NC}"
        echo "This will destroy the $WORKSPACE environment!"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" == "yes" ]; then
            terraform destroy -var-file="$TFVARS_FILE"
        else
            echo "Destroy cancelled"
        fi
        ;;
    *)
        echo "Usage: ./tf-deploy.sh [plan|apply|destroy]"
        exit 1
        ;;
esac
