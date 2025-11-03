#!/bin/bash

# ========================================
# Full DevOps Stack Deployment Script
# ========================================

set -e

echo "🚀 Starting Full DevOps Stack Deployment..."
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Variables
APP_DIR="application/python"
IMAGE_NAME="hello-python"
VERSION="v$(date +%s)"

# ========================================
# Stage 1: Run Tests
# ========================================
echo -e "${BLUE}🧪 Stage 1: Running Tests...${NC}"
cd $APP_DIR

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment and install dependencies
source venv/bin/activate
pip install -q -r requirements.txt

# Run tests
python -m pytest tests/ -v --cov=app --cov-report=term-missing || {
    echo -e "${RED}❌ Tests failed!${NC}"
    deactivate
    exit 1
}

deactivate
cd ../..
echo -e "${GREEN}✅ All tests passed!${NC}"
echo ""

# ========================================
# Stage 2: Security Scan
# ========================================
echo -e "${BLUE}🔒 Stage 2: Security Scanning...${NC}"
if command -v trivy &> /dev/null; then
    trivy fs --severity HIGH,CRITICAL $APP_DIR || echo "⚠️  Security issues found"
else
    echo "⚠️  Trivy not installed, skipping security scan"
fi
echo ""

# ========================================
# Stage 3: Build Docker Image
# ========================================
echo -e "${BLUE}📦 Stage 3: Building Docker Image...${NC}"
cd $APP_DIR
docker build -t $IMAGE_NAME:$VERSION -t $IMAGE_NAME:latest .
cd ../..
echo -e "${GREEN}✅ Docker image built successfully!${NC}"
echo ""

# ========================================
# Stage 4: Test Docker Image
# ========================================
echo -e "${BLUE}🧪 Stage 4: Testing Docker Image...${NC}"
docker run -d -p 8081:8080 --name test-container $IMAGE_NAME:latest
sleep 5

if curl -f http://localhost:8081/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker image test passed!${NC}"
else
    echo -e "${RED}❌ Docker image test failed!${NC}"
    docker stop test-container
    docker rm test-container
    exit 1
fi

docker stop test-container
docker rm test-container
echo ""

# ========================================
# Stage 5: Load to Minikube
# ========================================
echo -e "${BLUE}📤 Stage 5: Loading images to Minikube...${NC}"
minikube image load $IMAGE_NAME:$VERSION
minikube image load $IMAGE_NAME:latest
echo -e "${GREEN}✅ Images loaded to Minikube!${NC}"
echo ""

# ========================================
# Stage 6: Deploy Infrastructure
# ========================================
echo -e "${BLUE}🗄️  Stage 6: Deploying Infrastructure...${NC}"

# Deploy PostgreSQL
echo "Deploying PostgreSQL..."
kubectl apply -f kubernetes/postgres.yaml
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s || echo "⚠️  PostgreSQL taking longer than expected"

# Deploy Redis
echo "Deploying Redis..."
kubectl apply -f kubernetes/redis.yaml
kubectl wait --for=condition=ready pod -l app=redis --timeout=60s || echo "⚠️  Redis taking longer than expected"

echo -e "${GREEN}✅ Infrastructure deployed!${NC}"
echo ""

# ========================================
# Stage 7: Deploy Application
# ========================================
echo -e "${BLUE}🚢 Stage 7: Deploying Application...${NC}"

# Update image in deployment
kubectl apply -f kubernetes/app-full.yaml

# Wait for rollout
echo "Waiting for application rollout..."
kubectl rollout status deployment/hello-deployment --timeout=180s

echo -e "${GREEN}✅ Application deployed!${NC}"
echo ""

# ========================================
# Stage 8: Deploy Monitoring
# ========================================
echo -e "${BLUE}📊 Stage 8: Deploying Monitoring Stack...${NC}"

kubectl apply -f kubernetes/monitoring.yaml
kubectl wait --for=condition=ready pod -l app=prometheus --timeout=120s || echo "⚠️  Prometheus taking longer"
kubectl wait --for=condition=ready pod -l app=grafana --timeout=120s || echo "⚠️  Grafana taking longer"

echo -e "${GREEN}✅ Monitoring stack deployed!${NC}"
echo ""

# ========================================
# Stage 9: Verify Deployment
# ========================================
echo -e "${BLUE}🔍 Stage 9: Verifying deployment...${NC}"
echo ""

echo "=== Pods ==="
kubectl get pods
echo ""

echo "=== Services ==="
kubectl get services
echo ""

echo "=== HPA ==="
kubectl get hpa
echo ""

# ========================================
# Stage 10: Get Access URLs
# ========================================
echo -e "${BLUE}🌐 Stage 10: Access Information${NC}"
echo ""

APP_URL=$(minikube service hello-service --url)
PROMETHEUS_URL=$(minikube service prometheus --url)
GRAFANA_URL=$(minikube service grafana --url)

echo -e "${GREEN}🎉 Deployment Complete!${NC}"
echo ""
echo "=== Access URLs ==="
echo -e "${YELLOW}Application:${NC}  $APP_URL"
echo -e "${YELLOW}Prometheus:${NC}   $PROMETHEUS_URL"
echo -e "${YELLOW}Grafana:${NC}      $GRAFANA_URL (admin/admin)"
echo ""

# Test application
echo "=== Testing Application ===" 
echo "Main page:"
curl -s $APP_URL
echo ""
echo ""
echo "Health check:"
curl -s $APP_URL/health | python3 -m json.tool 2>/dev/null || curl -s $APP_URL/health
echo ""
echo ""
echo "Metrics (first 10 lines):"
curl -s $APP_URL/metrics | head -10
echo ""

echo -e "${GREEN}✅ Full DevOps Stack is ready!${NC}"
echo ""
echo "=== Next Steps ==="
echo "1. Open Grafana: $GRAFANA_URL"
echo "2. Add Prometheus datasource: $PROMETHEUS_URL"
echo "3. Create dashboards for your metrics"
echo "4. Monitor your application!"
echo ""
echo "=== Useful Commands ==="
echo "kubectl get all                    # View all resources"
echo "kubectl logs -l app=hello          # View app logs"
echo "kubectl top pods                   # View resource usage"
echo "minikube dashboard                 # Open Kubernetes dashboard"
