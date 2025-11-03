# ⚡ مرجع سريع - Quick Reference

## 🐳 Docker Commands

```bash
# بناء image
docker build -t hello-python:v1 .

# تشغيل container
docker run -d -p 8080:8080 --name my-app hello-python:v1

# عرض containers الشغالة
docker ps

# عرض logs
docker logs my-app

# إيقاف container
docker stop my-app

# حذف container
docker rm my-app

# عرض images
docker images

# حذف image
docker rmi hello-python:v1

# تنظيف كل شيء
docker system prune -a
```

---

## ☸️ Kubernetes Commands

### إدارة الـ Cluster
```bash
# بدء minikube
minikube start

# إيقاف minikube
minikube stop

# حذف cluster
minikube delete

# حالة cluster
kubectl cluster-info

# عرض nodes
kubectl get nodes
```

### إدارة الـ Deployments
```bash
# نشر تطبيق
kubectl apply -f kubernetes/hello-local.yaml

# عرض deployments
kubectl get deployments

# تفاصيل deployment
kubectl describe deployment hello-deployment

# تحديث image
kubectl set image deployment/hello-deployment hello=hello-python:v2

# scale replicas
kubectl scale deployment hello-deployment --replicas=5

# حذف deployment
kubectl delete deployment hello-deployment
```

### إدارة الـ Pods
```bash
# عرض pods
kubectl get pods

# عرض pods مع labels
kubectl get pods -l app=hello

# تفاصيل pod
kubectl describe pod <pod-name>

# logs لـ pod
kubectl logs <pod-name>

# logs مباشرة (follow)
kubectl logs -f <pod-name>

# تنفيذ أمر داخل pod
kubectl exec -it <pod-name> -- /bin/bash

# حذف pod
kubectl delete pod <pod-name>
```

### إدارة الـ Services
```bash
# عرض services
kubectl get services

# تفاصيل service
kubectl describe service hello-service

# الحصول على URL (minikube)
minikube service hello-service --url

# حذف service
kubectl delete service hello-service
```

### Rollouts & Updates
```bash
# حالة rollout
kubectl rollout status deployment/hello-deployment

# تاريخ rollouts
kubectl rollout history deployment/hello-deployment

# التراجع عن آخر update
kubectl rollout undo deployment/hello-deployment

# التراجع لنسخة معينة
kubectl rollout undo deployment/hello-deployment --to-revision=2

# إيقاف rollout
kubectl rollout pause deployment/hello-deployment

# استئناف rollout
kubectl rollout resume deployment/hello-deployment
```

### Debugging
```bash
# عرض events
kubectl get events --sort-by=.metadata.creationTimestamp

# عرض كل الموارد
kubectl get all

# عرض في namespace معين
kubectl get all -n kube-system

# عرض yaml لـ resource
kubectl get deployment hello-deployment -o yaml

# عرض json
kubectl get pod <pod-name> -o json

# عرض endpoints
kubectl get endpoints

# port forwarding
kubectl port-forward pod/<pod-name> 8080:8080
```

---

## 🔄 CI/CD Commands

### Local Pipeline
```bash
# تشغيل CI/CD محلي
./local-ci-cd.sh

# بناء ورفع image لـ minikube
docker build -t hello-python:v2 application/python/
minikube image load hello-python:v2

# تحديث deployment
kubectl set image deployment/hello-deployment hello=hello-python:v2
kubectl rollout status deployment/hello-deployment
```

### Git Workflow
```bash
# عرض التغييرات
git status

# إضافة ملفات
git add .

# commit
git commit -m "Update application"

# push (يشغل GitHub Actions)
git push origin main

# عرض logs
git log --oneline
```

---

## 🔍 Monitoring & Inspection

```bash
# Dashboard
minikube dashboard

# عرض resource usage
kubectl top nodes
kubectl top pods

# watch pods (تحديث مباشر)
kubectl get pods -w

# عرض labels
kubectl get pods --show-labels

# filter بـ label
kubectl get pods -l app=hello,version=v2

# عرض namespaces
kubectl get namespaces

# عرض في namespace معين
kubectl get pods -n kube-system
```

---

## 🧪 Testing Commands

```bash
# اختبار التطبيق
curl http://192.168.49.2:30253

# اختبار health endpoint
curl http://192.168.49.2:30253/health

# اختبار متكرر (load testing بسيط)
for i in {1..100}; do curl http://192.168.49.2:30253; done

# مع timing
time curl http://192.168.49.2:30253

# عرض headers
curl -I http://192.168.49.2:30253
```

---

## 📦 Minikube Specific

```bash
# SSH للـ minikube node
minikube ssh

# عرض images في minikube
minikube image ls

# تحميل image لـ minikube
minikube image load hello-python:v1

# حذف image من minikube
minikube image rm hello-python:v1

# عرض addons
minikube addons list

# تفعيل addon
minikube addons enable metrics-server

# عرض IP
minikube ip

# فتح service في browser
minikube service hello-service
```

---

## 🛠️ Useful Aliases

أضف هذه في `~/.bashrc` أو `~/.zshrc`:

```bash
# Kubernetes shortcuts
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kga='kubectl get all'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'

# Docker shortcuts
alias d='docker'
alias dps='docker ps'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'

# Minikube shortcuts
alias mk='minikube'
alias mks='minikube start'
alias mkst='minikube stop'
alias mkd='minikube dashboard'
```

بعد إضافتها:
```bash
source ~/.bashrc  # أو ~/.zshrc
```

---

## 🎯 Common Workflows

### Workflow 1: تحديث التطبيق
```bash
# 1. عدل الكود
nano application/python/app.py

# 2. شغل CI/CD
./local-ci-cd.sh

# 3. تحقق
kubectl get pods
curl http://192.168.49.2:30253
```

### Workflow 2: Debug مشكلة
```bash
# 1. شوف الـ pods
kubectl get pods

# 2. شوف logs
kubectl logs <pod-name>

# 3. شوف events
kubectl describe pod <pod-name>

# 4. دخول للـ pod
kubectl exec -it <pod-name> -- /bin/bash
```

### Workflow 3: Rollback
```bash
# 1. شوف التاريخ
kubectl rollout history deployment/hello-deployment

# 2. ارجع
kubectl rollout undo deployment/hello-deployment

# 3. تحقق
kubectl rollout status deployment/hello-deployment
```

---

## 📝 YAML Snippets

### Deployment بسيط
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app:v1
        ports:
        - containerPort: 8080
```

### Service بسيط
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  selector:
    app: my-app
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30000
```

---

## 🆘 Emergency Commands

```bash
# حذف كل الـ pods في namespace
kubectl delete pods --all

# إعادة تشغيل deployment
kubectl rollout restart deployment/hello-deployment

# force delete pod
kubectl delete pod <pod-name> --force --grace-period=0

# تنظيف resources
kubectl delete all --all

# إعادة تشغيل minikube
minikube stop && minikube start
```

---

**💡 Tip**: احفظ هذا الملف في مكان سهل الوصول للرجوع إليه!
