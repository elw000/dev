#!/bin/bash

# ========================================
# Local CI/CD Pipeline Script
# ========================================

set -e  # توقف لو حصل أي خطأ

echo "🚀 Starting Local CI/CD Pipeline..."
echo ""

# الألوان للـ output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# المتغيرات
APP_DIR="application/python"
IMAGE_NAME="hello-python"
VERSION="v$(date +%s)"  # نسخة جديدة بناءً على الوقت
K8S_DEPLOYMENT="hello-deployment"

# ========================================
# المرحلة 1: Build & Test
# ========================================
echo -e "${BLUE}📦 Stage 1: Building Docker Image...${NC}"
cd $APP_DIR
docker build -t $IMAGE_NAME:$VERSION -t $IMAGE_NAME:latest .
cd ../..
echo -e "${GREEN}✅ Docker image built successfully!${NC}"
echo ""

# ========================================
# المرحلة 2: Test
# ========================================
echo -e "${BLUE}🧪 Stage 2: Testing Docker Image...${NC}"
# شغل container للاختبار
docker run -d -p 8081:8080 --name test-container $IMAGE_NAME:latest
sleep 3

# اختبر التطبيق
if curl -f http://localhost:8081 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Application test passed!${NC}"
else
    echo -e "${RED}❌ Application test failed!${NC}"
    docker stop test-container
    docker rm test-container
    exit 1
fi

# نضف الـ container
docker stop test-container
docker rm test-container
echo ""

# ========================================
# المرحلة 3: Load to Minikube
# ========================================
echo -e "${BLUE}📤 Stage 3: Loading image to Minikube...${NC}"
minikube image load $IMAGE_NAME:$VERSION
minikube image load $IMAGE_NAME:latest
echo -e "${GREEN}✅ Image loaded to Minikube!${NC}"
echo ""

# ========================================
# المرحلة 4: Deploy to Kubernetes
# ========================================
echo -e "${BLUE}🚢 Stage 4: Deploying to Kubernetes...${NC}"

# تحديث الصورة في الـ deployment
kubectl set image deployment/$K8S_DEPLOYMENT hello=$IMAGE_NAME:$VERSION --record

# انتظار اكتمال الـ rollout
echo "Waiting for rollout to complete..."
kubectl rollout status deployment/$K8S_DEPLOYMENT

echo -e "${GREEN}✅ Deployment completed!${NC}"
echo ""

# ========================================
# المرحلة 5: Verify
# ========================================
echo -e "${BLUE}🔍 Stage 5: Verifying deployment...${NC}"
echo ""
echo "Pods:"
kubectl get pods -l app=hello
echo ""
echo "Service:"
kubectl get service hello-service
echo ""

# الحصول على الـ URL
SERVICE_URL=$(minikube service hello-service --url)
echo -e "${GREEN}🎉 Deployment successful!${NC}"
echo -e "${YELLOW}Access your app at: $SERVICE_URL${NC}"
echo ""

# اختبار نهائي
echo "Testing the deployed application..."
if curl -f $SERVICE_URL > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Application is running successfully!${NC}"
    curl $SERVICE_URL
else
    echo -e "${RED}⚠️  Application might not be ready yet. Try again in a few seconds.${NC}"
fi

echo ""
echo -e "${GREEN}🎊 CI/CD Pipeline completed successfully!${NC}"
