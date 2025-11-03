#!/bin/bash

# ========================================
# Minikube Setup Script
# ========================================

set -e

echo "🚀 Setting up Minikube for Full DevOps Stack..."
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if minikube is running
if minikube status &> /dev/null; then
    echo -e "${YELLOW}⚠️  Minikube is already running${NC}"
    echo "Do you want to delete and recreate with more resources? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🗑️  Deleting existing cluster...${NC}"
        minikube delete
    else
        echo -e "${YELLOW}⚠️  Keeping existing cluster${NC}"
        echo "Note: You may need more resources for the full stack"
        echo "Current resources:"
        minikube config view
        exit 0
    fi
fi

# Start Minikube with proper resources
echo -e "${BLUE}🚀 Starting Minikube with 4 CPUs and 8GB RAM...${NC}"
minikube start --cpus=4 --memory=8192 --driver=docker

# Enable metrics-server for HPA
echo -e "${BLUE}📊 Enabling metrics-server addon...${NC}"
minikube addons enable metrics-server

# Verify
echo ""
echo -e "${GREEN}✅ Minikube is ready!${NC}"
echo ""
echo "Cluster info:"
kubectl cluster-info
echo ""
echo "Node status:"
kubectl get nodes
echo ""
echo -e "${GREEN}🎉 You can now run: ./deploy-full-stack.sh${NC}"
