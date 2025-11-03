# 🚀 Hello to Kubernetes - دليل شامل بالعربية

> رحلة كاملة من تطبيق بسيط إلى CI/CD متكامل على Kubernetes

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)](https://www.python.org/)

---

## 📋 المحتويات

- [نظرة عامة](#-نظرة-عامة)
- [البدء السريع](#-البدء-السريع)
- [المتطلبات](#-المتطلبات)
- [التثبيت](#-التثبيت)
- [الاستخدام](#-الاستخدام)
- [CI/CD](#-cicd)
- [التوثيق](#-التوثيق)
- [استكشاف الأخطاء](#-استكشاف-الأخطاء)

---

## 🎯 نظرة عامة

هذا المشروع يوضح:
- ✅ كيفية containerize تطبيق باستخدام **Docker**
- ✅ كيفية نشر التطبيق على **Kubernetes**
- ✅ كيفية بناء **CI/CD pipeline** متكامل
- ✅ أفضل الممارسات في DevOps

### ما ستتعلمه:
1. **Docker**: بناء وإدارة Containers
2. **Kubernetes**: Orchestration وإدارة التطبيقات
3. **CI/CD**: أتمتة البناء والنشر
4. **DevOps**: مفاهيم وأدوات أساسية

---

## ⚡ البدء السريع

```bash
# 1. استنساخ المشروع
git clone https://github.com/fduran/hello2k8s.git
cd hello2k8s

# 2. بدء Minikube
minikube start

# 3. تشغيل CI/CD Pipeline
./local-ci-cd.sh

# 4. اختبار التطبيق
curl $(minikube service hello-service --url)
```

**النتيجة المتوقعة:**
```
🚀 Hello from Kubernetes!
📦 Version: v2.0-cicd
🖥️  Pod: hello-deployment-xxxxx
```

---

## 📦 المتطلبات

### الأدوات الأساسية:
- [Docker](https://docs.docker.com/get-docker/) (v20.10+)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (v1.20+)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/) (v1.25+)

### اختياري (للإنتاج):
- حساب [Docker Hub](https://hub.docker.com/)
- حساب [GitHub](https://github.com/)
- Kubernetes cluster (GKE, EKS, AKS)

---

## 🔧 التثبيت

### 1. تثبيت Docker
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# التحقق
docker --version
```

### 2. تثبيت kubectl
```bash
# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# التحقق
kubectl version --client
```

### 3. تثبيت Minikube
```bash
# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# التحقق
minikube version
```

### 4. بدء Minikube
```bash
minikube start --driver=docker
kubectl cluster-info
```

---

## 🎮 الاستخدام

### السيناريو 1: Docker فقط

```bash
# الانتقال لمجلد التطبيق
cd application/python

# بناء Image
docker build -t hello-python:v1 .

# تشغيل Container
docker run -d -p 8080:8080 --name hello hello-python:v1

# اختبار
curl http://localhost:8080

# التنظيف
docker stop hello && docker rm hello
```

### السيناريو 2: Kubernetes محلي

```bash
# بناء وتحميل Image
cd application/python
docker build -t hello-python:v1 .
minikube image load hello-python:v1

# نشر على Kubernetes
cd ../..
kubectl apply -f kubernetes/hello-local.yaml

# الحصول على URL
minikube service hello-service --url

# اختبار
curl $(minikube service hello-service --url)

# مراقبة
kubectl get pods -w
```

### السيناريو 3: CI/CD الكامل

```bash
# تشغيل Pipeline المحلي
./local-ci-cd.sh

# النتيجة:
# ✅ Build Docker Image
# ✅ Test Application
# ✅ Load to Minikube
# ✅ Deploy to Kubernetes
# ✅ Verify Deployment
```

---

## 🔄 CI/CD

### Pipeline المحلي

يتم تشغيله بأمر واحد:
```bash
./local-ci-cd.sh
```

**المراحل:**
1. **Build** - بناء Docker Image جديدة
2. **Test** - اختبار التطبيق
3. **Load** - تحميل Image في Minikube
4. **Deploy** - نشر على Kubernetes
5. **Verify** - التحقق من النشر

### GitHub Actions

للنشر التلقائي عند كل `git push`:

1. **إعداد Secrets في GitHub:**
   - `DOCKER_USERNAME` - اسم المستخدم في Docker Hub
   - `DOCKER_PASSWORD` - كلمة المرور أو Token
   - `KUBE_CONFIG` - ملف kubeconfig (مشفر base64)

2. **Push للكود:**
   ```bash
   git add .
   git commit -m "Update application"
   git push origin main
   ```

3. **GitHub Actions يشتغل تلقائياً!**

راجع [CI-CD-GUIDE.md](CI-CD-GUIDE.md) للتفاصيل الكاملة.

---

## 📚 التوثيق

| الملف | الوصف |
|------|-------|
| [DEMO.md](DEMO.md) | عرض توضيحي كامل |
| [CI-CD-GUIDE.md](CI-CD-GUIDE.md) | دليل CI/CD شامل |
| [QUICK-REFERENCE.md](QUICK-REFERENCE.md) | مرجع سريع للأوامر |
| [PROJECT-SUMMARY.md](PROJECT-SUMMARY.md) | ملخص المشروع |

---

## 🎓 أمثلة عملية

### مثال 1: تحديث التطبيق

```bash
# 1. عدل الكود
nano application/python/app.py

# 2. شغل CI/CD
./local-ci-cd.sh

# 3. شوف التحديث
curl $(minikube service hello-service --url)
```

### مثال 2: Scale Up/Down

```bash
# زيادة عدد Pods
kubectl scale deployment hello-deployment --replicas=5

# مراقبة
kubectl get pods -w

# تقليل
kubectl scale deployment hello-deployment --replicas=2
```

### مثال 3: Rollback

```bash
# شوف التاريخ
kubectl rollout history deployment/hello-deployment

# التراجع
kubectl rollout undo deployment/hello-deployment

# التحقق
kubectl rollout status deployment/hello-deployment
```

---

## 🐛 استكشاف الأخطاء

### المشكلة: Pods لا تعمل

```bash
# فحص حالة Pods
kubectl get pods

# تفاصيل Pod
kubectl describe pod <pod-name>

# عرض Logs
kubectl logs <pod-name>
```

### المشكلة: Service لا يستجيب

```bash
# فحص Service
kubectl get service hello-service

# فحص Endpoints
kubectl get endpoints hello-service

# اختبار من داخل Cluster
kubectl run test --rm -it --image=busybox -- wget -qO- hello-service:8080
```

### المشكلة: Image لا يتحدث

```bash
# التأكد من وجود Image في Minikube
minikube image ls | grep hello-python

# إعادة تحميل
minikube image load hello-python:v1

# فحص imagePullPolicy
kubectl get deployment hello-deployment -o yaml | grep imagePullPolicy
```

---

## 🛠️ الأوامر المفيدة

```bash
# عرض كل الموارد
kubectl get all

# Dashboard
minikube dashboard

# Logs لكل Pods
kubectl logs -l app=hello --tail=50

# Port Forwarding
kubectl port-forward deployment/hello-deployment 8080:8080

# تنفيذ أمر داخل Pod
kubectl exec -it <pod-name> -- /bin/bash

# تنظيف
kubectl delete -f kubernetes/hello-local.yaml
minikube stop
```

---

## 🏗️ البنية المعمارية

```
┌─────────────────────────────────────────────┐
│           Developer Machine                 │
│  ┌──────────┐         ┌─────────────┐      │
│  │   Code   │────────▶│   Docker    │      │
│  └──────────┘         └──────┬──────┘      │
│                              │              │
│                              ▼              │
│                       ┌─────────────┐       │
│                       │  Minikube   │       │
│                       │ (Kubernetes)│       │
│                       └──────┬──────┘       │
│                              │              │
│         ┌────────────────────┼────────┐     │
│         ▼                    ▼        ▼     │
│    ┌────────┐          ┌────────┐ ┌────┐   │
│    │ Pod 1  │          │ Pod 2  │ │Svc │   │
│    └────────┘          └────────┘ └────┘   │
└─────────────────────────────────────────────┘
```

---

## 🤝 المساهمة

نرحب بالمساهمات! يمكنك:
1. Fork المشروع
2. إنشاء Branch جديد (`git checkout -b feature/amazing`)
3. Commit التغييرات (`git commit -m 'Add amazing feature'`)
4. Push للـ Branch (`git push origin feature/amazing`)
5. فتح Pull Request

---

## 📝 الترخيص

هذا المشروع مفتوح المصدر ومتاح للاستخدام التعليمي.

---

## 🌟 الميزات

- ✅ **سهل الفهم** - شرح بالعربية خطوة بخطوة
- ✅ **عملي** - أمثلة حقيقية قابلة للتشغيل
- ✅ **شامل** - من Docker إلى CI/CD
- ✅ **محلي** - يعمل على جهازك بدون تكلفة
- ✅ **موثق** - توثيق كامل بالعربية
- ✅ **جاهز للإنتاج** - يمكن نقله لـ GKE/EKS/AKS

---

## 🎯 الخطوات التالية

بعد إتمام هذا المشروع، يمكنك:

1. **تعلم Helm** - إدارة Kubernetes packages
2. **إضافة Monitoring** - Prometheus + Grafana
3. **إضافة Logging** - ELK Stack
4. **تجربة Service Mesh** - Istio
5. **النشر على Cloud** - GKE, EKS, أو AKS
6. **تعلم GitOps** - ArgoCD أو Flux

---

## 📞 الدعم

- 📖 [التوثيق الكامل](CI-CD-GUIDE.md)
- 🔍 [استكشاف الأخطاء](QUICK-REFERENCE.md)
- 💡 [الأمثلة](DEMO.md)

---

## ⭐ إذا أعجبك المشروع

لا تنسى إضافة ⭐ للمشروع!

---

**صُنع بـ ❤️ للمتعلمين العرب**

**آخر تحديث:** نوفمبر 2025
