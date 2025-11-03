# 🔄 CI/CD Pipeline Setup Guide

## 🎯 الهدف

عند عمل `git push`، GitHub Actions تلقائياً:
1. ✅ Run tests
2. ✅ Build Docker image
3. ✅ Push to Docker Hub
4. ✅ Deploy to Kubernetes

---

## 📋 الخطوات

### **الخطوة 1: إنشاء Docker Hub Account**

1. اذهب إلى [hub.docker.com](https://hub.docker.com)
2. سجل حساب جديد (مجاني)
3. احفظ username و password

---

### **الخطوة 2: إنشاء GitHub Repository**

```bash
# في مجلد المشروع
cd /home/elw00/Documents/kubernetes/hello2k8s

# Initialize git
git init

# Add all files
git add .

# First commit
git commit -m "Complete DevOps project with CI/CD"

# Create repo on GitHub
# اذهب إلى github.com وأنشئ repository جديد
# ثم:
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git branch -M main
git push -u origin main
```

---

### **الخطوة 3: إعداد GitHub Secrets**

في GitHub repository:

1. اذهب إلى: **Settings** → **Secrets and variables** → **Actions**
2. اضغط **"New repository secret"**

#### **Secret 1: DOCKER_USERNAME**
```
Name: DOCKER_USERNAME
Value: اسم المستخدم في Docker Hub
```

#### **Secret 2: DOCKER_PASSWORD**
```
Name: DOCKER_PASSWORD
Value: كلمة المرور أو Access Token
```

**للحصول على Access Token (أفضل من Password):**
1. اذهب إلى Docker Hub → Account Settings → Security
2. اضغط "New Access Token"
3. اسمه: `github-actions`
4. انسخ الـ token واستخدمه كـ DOCKER_PASSWORD

#### **Secret 3: KUBE_CONFIG** (اختياري)

**للـ auto-deploy على Kubernetes:**

```bash
# احصل على kubeconfig
cat ~/.kube/config | base64 -w 0

# انسخ الناتج
```

في GitHub Secrets:
```
Name: KUBE_CONFIG
Value: الناتج من الأمر السابق (base64 encoded)
```

---

### **الخطوة 4: تعديل الـ Workflow (اختياري)**

الملف موجود في: `.github/workflows/ci-cd.yaml`

**تعديلات محتملة:**

#### **1. تغيير اسم Docker Image:**
```yaml
env:
  DOCKER_IMAGE: your-app-name  # غير ده
```

#### **2. تغيير اسم الـ Deployment:**
```yaml
env:
  K8S_DEPLOYMENT: hello-deployment  # أو اسم deployment بتاعك
```

#### **3. إضافة Security Scanning:**
```yaml
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ${{ env.DOCKER_IMAGE }}:latest
    format: 'sarif'
    output: 'trivy-results.sarif'
```

---

## 🚀 الاستخدام

### **السيناريو 1: تعديل الكود**

```bash
# 1. عدل الكود
nano application/python/app.py

# 2. Commit
git add .
git commit -m "Update application"

# 3. Push
git push origin main

# 4. GitHub Actions يشتغل تلقائياً! 🎉
```

### **السيناريو 2: مراقبة الـ Pipeline**

1. اذهب إلى GitHub repository
2. اضغط على tab **"Actions"**
3. شوف الـ workflow بيشتغل live!

---

## 📊 مراحل الـ Pipeline

### **Stage 1: Build and Test**
```
✅ Checkout code
✅ Setup Python
✅ Install dependencies
✅ Run tests (pytest)
✅ Build Docker image
✅ Test Docker image
✅ Login to Docker Hub
✅ Push to Docker Hub
```

### **Stage 2: Deploy**
```
✅ Checkout code
✅ Setup kubectl
✅ Configure kubectl
✅ Update Kubernetes deployment
✅ Wait for rollout
✅ Verify deployment
```

---

## 🐛 استكشاف الأخطاء

### **المشكلة 1: Tests failed**

```bash
# جرب الـ tests محلياً
cd application/python
pytest tests/ -v
```

### **المشكلة 2: Docker login failed**

تأكد من:
- ✅ DOCKER_USERNAME صحيح
- ✅ DOCKER_PASSWORD صحيح (أو Access Token)
- ✅ الـ Secrets مكتوبة بنفس الأسماء بالضبط

### **المشكلة 3: Deployment failed**

تأكد من:
- ✅ KUBE_CONFIG موجود وصحيح
- ✅ اسم الـ deployment صحيح
- ✅ الـ cluster accessible من GitHub Actions

---

## 🎯 أمثلة عملية

### **مثال 1: تحديث Version**

```bash
# عدل version في app.py
nano application/python/app.py
# غير: APP_VERSION = "v2.0-devops-full"
# إلى:  APP_VERSION = "v2.1-new-feature"

git add .
git commit -m "Update to v2.1"
git push origin main

# GitHub Actions يبني ويرفع النسخة الجديدة تلقائياً!
```

### **مثال 2: إضافة Feature جديد**

```python
# في app.py، أضف endpoint جديد
@app.route('/api/status')
def status():
    return jsonify({
        "status": "running",
        "uptime": "1h 30m"
    })
```

```bash
git add .
git commit -m "Add status endpoint"
git push origin main

# Pipeline يختبر، يبني، وينشر تلقائياً!
```

---

## 📈 Monitoring الـ Pipeline

### **في GitHub:**
- اذهب إلى **Actions** tab
- شوف الـ workflow runs
- اضغط على أي run لشوف التفاصيل
- شوف logs لكل step

### **في Kubernetes:**
```bash
# شوف الـ rollout
kubectl rollout status deployment/hello-deployment

# شوف الـ history
kubectl rollout history deployment/hello-deployment

# شوف الـ pods الجديدة
kubectl get pods -w
```

---

## 🔒 Security Best Practices

### **1. استخدم Access Tokens بدل Passwords**
```
Docker Hub → Settings → Security → New Access Token
```

### **2. لا تكتب Secrets في الكود**
```bash
# ❌ خطأ
DOCKER_PASSWORD="mypassword123"

# ✅ صح
DOCKER_PASSWORD="${{ secrets.DOCKER_PASSWORD }}"
```

### **3. استخدم Branch Protection**
```
GitHub → Settings → Branches → Add rule
- Require pull request reviews
- Require status checks to pass
```

---

## 🎓 الخطوات التالية

### **1. إضافة Environments**
```yaml
environment:
  name: production
  url: http://your-app.com
```

### **2. إضافة Manual Approval**
```yaml
- name: Wait for approval
  uses: trstringer/manual-approval@v1
```

### **3. إضافة Notifications**
```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
```

---

## 📚 الموارد

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Docker Hub](https://hub.docker.com)
- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

---

## ✅ Checklist

قبل Push:
- [ ] Tests تعمل محلياً
- [ ] Docker image يبني بنجاح
- [ ] GitHub Secrets معدّة
- [ ] Workflow file صحيح
- [ ] Commit message واضح

---

**🎉 الآن عندك CI/CD Pipeline كامل!**

**كل push = Automated deployment!** 🚀
