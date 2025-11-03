# 🚀 دليل CI/CD الكامل

## 📋 المحتويات
1. [CI/CD المحلي (Local)](#local-cicd)
2. [CI/CD مع GitHub Actions](#github-actions-cicd)
3. [شرح الـ Pipeline](#pipeline-explanation)

---

## 🏠 Local CI/CD

### التشغيل السريع:
```bash
./local-ci-cd.sh
```

### ماذا يحدث؟
1. ✅ **Build**: بناء Docker Image جديدة
2. ✅ **Test**: اختبار التطبيق
3. ✅ **Load**: تحميل الصورة في Minikube
4. ✅ **Deploy**: نشر على Kubernetes
5. ✅ **Verify**: التحقق من النشر

### المتطلبات:
- Docker
- Minikube (شغال)
- kubectl

---

## 🌐 GitHub Actions CI/CD

### الإعداد الأولي:

#### 1️⃣ إنشاء حساب Docker Hub
1. اذهب إلى [hub.docker.com](https://hub.docker.com)
2. سجل حساب جديد (مجاني)
3. احفظ username و password

#### 2️⃣ إعداد GitHub Secrets
في مستودع GitHub الخاص بك:

1. اذهب إلى **Settings** → **Secrets and variables** → **Actions**
2. أضف الـ Secrets التالية:

| Secret Name | القيمة | الوصف |
|------------|--------|-------|
| `DOCKER_USERNAME` | username بتاعك | اسم المستخدم في Docker Hub |
| `DOCKER_PASSWORD` | password أو token | كلمة المرور أو Access Token |
| `KUBE_CONFIG` | محتوى ملف kubeconfig | للاتصال بالـ cluster (مشفر base64) |

#### 3️⃣ الحصول على KUBE_CONFIG

**للـ Minikube المحلي:**
```bash
# احصل على الـ kubeconfig
cat ~/.kube/config | base64 -w 0

# انسخ الناتج وضعه في GitHub Secret
```

**لـ GKE أو أي cluster آخر:**
```bash
# احصل على credentials الـ cluster
kubectl config view --flatten --minify | base64 -w 0
```

---

## 🔄 شرح الـ Pipeline

### المرحلة 1: Build & Test
```yaml
- Checkout الكود من Git
- تثبيت Python والمكتبات
- تشغيل الاختبارات
- بناء Docker Image
- اختبار الـ Image
```

### المرحلة 2: Push to Registry
```yaml
- تسجيل الدخول لـ Docker Hub
- رفع الصورة بـ tag فريد (commit SHA)
- رفع الصورة بـ tag "latest"
```

### المرحلة 3: Deploy to Kubernetes
```yaml
- إعداد kubectl
- الاتصال بالـ cluster
- تحديث الـ Deployment
- انتظار اكتمال الـ Rollout
- التحقق من النشر
```

---

## 🎯 كيف تستخدم الـ CI/CD؟

### السيناريو الكامل:

1. **عدل الكود:**
   ```bash
   cd application/python
   nano app.py  # عدل التطبيق
   ```

2. **اختبر محلياً:**
   ```bash
   ./local-ci-cd.sh
   ```

3. **ارفع على GitHub:**
   ```bash
   git add .
   git commit -m "Update application"
   git push origin main
   ```

4. **GitHub Actions يشتغل تلقائياً!**
   - شوف التقدم في: `Actions` tab على GitHub
   - بعد دقائق، التطبيق الجديد يكون شغال!

---

## 📊 مراقبة الـ Pipeline

### على GitHub:
```
Repository → Actions → اختر آخر workflow run
```

### محلياً:
```bash
# شوف الـ Pods
kubectl get pods -w

# شوف logs الـ deployment
kubectl logs -f deployment/hello-deployment

# شوف تاريخ الـ rollouts
kubectl rollout history deployment/hello-deployment
```

---

## 🔧 استكشاف الأخطاء

### المشكلة: Deployment فشل
```bash
# شوف حالة الـ pods
kubectl get pods

# شوف تفاصيل pod معين
kubectl describe pod <pod-name>

# شوف الـ logs
kubectl logs <pod-name>
```

### المشكلة: Image مش موجودة
```bash
# تأكد إن الصورة موجودة في Minikube
minikube image ls | grep hello-python

# حمل الصورة يدوياً
minikube image load hello-python:latest
```

### المشكلة: GitHub Actions فشل
1. اذهب إلى Actions tab
2. افتح الـ failed workflow
3. شوف الـ logs لكل step
4. تأكد من الـ Secrets صحيحة

---

## 🎓 مفاهيم متقدمة

### Rolling Update
Kubernetes بيحدث التطبيق بدون downtime:
```bash
# شوف الـ rollout strategy
kubectl describe deployment hello-deployment

# تراجع عن آخر update
kubectl rollout undo deployment/hello-deployment
```

### Blue-Green Deployment
نشر نسخة جديدة بجانب القديمة:
```bash
# عدل الـ deployment ليستخدم labels مختلفة
# ثم غير الـ Service ليشير للنسخة الجديدة
```

### Canary Deployment
نشر تدريجي لنسبة صغيرة من المستخدمين:
```yaml
# عدل replicas في deployment
replicas: 5  # 4 قديم + 1 جديد
```

---

## 📚 موارد إضافية

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Docker Hub](https://hub.docker.com)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

## ✅ Checklist للإنتاج

- [ ] اختبارات تلقائية (Unit Tests)
- [ ] فحص الأمان (Security Scanning)
- [ ] مراقبة التطبيق (Monitoring)
- [ ] Logging مركزي
- [ ] Backup للـ Database
- [ ] SSL/TLS Certificates
- [ ] Resource Limits في K8s
- [ ] Health Checks
- [ ] Rollback Strategy

---

**🎉 مبروك! عندك الآن CI/CD pipeline كامل!**
