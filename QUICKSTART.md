# ⚡ Quick Start Guide

## 🚀 البدء السريع في 3 خطوات

### الخطوة 1: إعداد Minikube

```bash
# إذا كان Minikube يعمل بالفعل بموارد قليلة، احذفه وأعد إنشاءه
./setup-minikube.sh
```

**أو يدوياً:**
```bash
# احذف الـ cluster القديم
minikube delete

# ابدأ cluster جديد بموارد كافية
minikube start --cpus=4 --memory=8192 --driver=docker

# فعّل metrics server
minikube addons enable metrics-server
```

---

### الخطوة 2: نشر المشروع الكامل

```bash
./deploy-full-stack.sh
```

**هذا الأمر سيقوم بـ:**
1. ✅ إنشاء virtual environment
2. ✅ تشغيل الاختبارات
3. ✅ فحص الأمان
4. ✅ بناء Docker image
5. ✅ نشر PostgreSQL
6. ✅ نشر Redis
7. ✅ نشر التطبيق
8. ✅ نشر Monitoring (Prometheus + Grafana)
9. ✅ عرض URLs للوصول

---

### الخطوة 3: الوصول للتطبيقات

بعد اكتمال النشر، ستحصل على URLs مثل:

```
Application:  http://192.168.49.2:30253
Prometheus:   http://192.168.49.2:30090
Grafana:      http://192.168.49.2:30030 (admin/admin)
```

**اختبر التطبيق:**
```bash
# Home page
curl http://192.168.49.2:30253

# Health check
curl http://192.168.49.2:30253/health

# Metrics
curl http://192.168.49.2:30253/metrics
```

---

## 🐛 حل المشاكل الشائعة

### المشكلة 1: Python environment error

**الخطأ:**
```
error: externally-managed-environment
```

**الحل:**
السكريبت الآن يستخدم virtual environment تلقائياً! ✅

---

### المشكلة 2: Minikube موارد غير كافية

**الخطأ:**
```
You cannot change the memory/CPUs for an existing cluster
```

**الحل:**
```bash
# احذف وأعد الإنشاء
minikube delete
minikube start --cpus=4 --memory=8192
```

**أو استخدم:**
```bash
./setup-minikube.sh
```

---

### المشكلة 3: Pods لا تعمل

**التحقق:**
```bash
# شوف حالة الـ pods
kubectl get pods

# شوف التفاصيل
kubectl describe pod <pod-name>

# شوف الـ logs
kubectl logs <pod-name>
```

**الحلول الشائعة:**
```bash
# إعادة تشغيل deployment
kubectl rollout restart deployment/hello-deployment

# حذف pod (سيتم إنشاء واحد جديد)
kubectl delete pod <pod-name>

# التحقق من الـ events
kubectl get events --sort-by='.lastTimestamp'
```

---

### المشكلة 4: Image لا يتم سحبه

**الخطأ:**
```
ImagePullBackOff
```

**الحل:**
```bash
# تأكد من تحميل الصورة في Minikube
cd application/python
docker build -t hello-python:latest .
minikube image load hello-python:latest

# تحقق من وجود الصورة
minikube image ls | grep hello-python
```

---

## 📊 التحقق من النشر

### 1. شوف كل الموارد
```bash
kubectl get all
```

### 2. شوف الـ Pods
```bash
kubectl get pods -w
```

### 3. شوف الـ Services
```bash
kubectl get services
```

### 4. شوف الـ HPA (Auto-scaling)
```bash
kubectl get hpa
```

### 5. شوف استخدام الموارد
```bash
kubectl top nodes
kubectl top pods
```

---

## 🧹 التنظيف

### حذف كل شيء
```bash
# حذف كل الموارد
kubectl delete -f kubernetes/postgres.yaml
kubectl delete -f kubernetes/redis.yaml
kubectl delete -f kubernetes/app-full.yaml
kubectl delete -f kubernetes/monitoring.yaml

# أو حذف كل شيء
kubectl delete all --all

# حذف الـ cluster
minikube delete
```

---

## 🎯 الأوامر المفيدة

### Monitoring
```bash
# Logs
kubectl logs -f deployment/hello-deployment

# Describe
kubectl describe deployment hello-deployment

# Events
kubectl get events --sort-by='.lastTimestamp'
```

### Scaling
```bash
# Manual scaling
kubectl scale deployment/hello-deployment --replicas=5

# Check HPA
kubectl get hpa -w
```

### Debugging
```bash
# Execute in pod
kubectl exec -it <pod-name> -- /bin/bash

# Port forward
kubectl port-forward deployment/hello-deployment 8080:8080

# Copy files
kubectl cp <pod-name>:/path/to/file ./local-file
```

---

## 📚 الخطوات التالية

بعد النشر الناجح:

1. **افتح Grafana** وأضف Prometheus datasource
2. **استكشف Prometheus** وجرب queries
3. **اختبر Auto-scaling** بعمل load testing
4. **راقب الـ logs** وشوف structured logging
5. **جرب Rolling update** بتعديل التطبيق

---

## 🆘 المساعدة

إذا واجهت مشاكل:

1. راجع [DEVOPS-COMPLETE-GUIDE.md](DEVOPS-COMPLETE-GUIDE.md)
2. راجع [QUICK-REFERENCE.md](QUICK-REFERENCE.md)
3. شوف [DEMO.md](DEMO.md) للأمثلة
4. استخدم `kubectl describe` و `kubectl logs`

---

## ✅ Checklist

قبل البدء، تأكد من:
- [ ] Docker مثبت ويعمل
- [ ] kubectl مثبت
- [ ] Minikube مثبت
- [ ] Python 3.9+ مثبت
- [ ] 4 CPU cores متاحة
- [ ] 8GB RAM متاحة
- [ ] 10GB disk space متاح

---

**🎉 استمتع بمشروع DevOps الكامل!**
