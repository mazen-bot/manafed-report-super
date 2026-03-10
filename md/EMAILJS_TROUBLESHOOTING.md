# حل مشكلة "EmailJS library not loaded"

## 🔍 المشكلة
عند فتح النظام، تظهر رسالة خطأ:
```
❌ EmailJS library not loaded
```

---

## 🛠️ الحلول (مرتبة حسب الأولوية)

### ✅ الحل 1: التحقق من سرعة الإنترنت
المشكلة الأولى والأكثر شيوعًا هي عدم تحميل المكتبة من CDN بسبب سوء الاتصال.

**الخطوات:**
1. تأكد من وجود اتصال إنترنت جيد
2. افتح DevTools (F12)
3. اذهب إلى Network tab
4. ابحث عن: `email.min.js`
5. تحقق من أن status هو 200 وليس 404 أو timeout

**ماذا لو كان هناك خطأ؟**
- إذا كان 404: CDN قد يكون معطل (جرب تحديث الصفحة)
- إذا كان timeout: اتصالك بطيء جداً

---

### ✅ الحل 2: تجربة CDN بديل
إذا كان cdn.jsdelivr.net مُحجوب أو قد يكون معطل، جرب بديل:

**خيار أ: استخدام CDN آخر**

افتح `hr-management.html` وابحث عن:
```html
<script src="https://cdn.jsdelivr.net/npm/@emailjs/browser@4/dist/build/email.min.js"></script>
```

استبدله بأحد البدائل:

**بديل 1 - jsDelivr (بديل سريع):**
```html
<script src="https://cdn.jsdelivr.net/npm/@emailjs/browser@4.2.0/dist/build/email.min.js"></script>
```

**بديل 2 - unpkg:**
```html
<script src="https://unpkg.com/@emailjs/browser@4/dist/build/email.min.js"></script>
```

**بديل 3 - cdnjs:**
```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/emailjs-com/3.2.0/email.min.js"></script>
```

---

### ✅ الحل 3: إزالة `async` من script
عديل في ملف `hr-management.html` (سطر 884):

**قبل:**
```html
<script async src="https://cdn.jsdelivr.net/npm/@emailjs/browser@4/dist/build/email.min.js"></script>
```

**بعد:**
```html
<script src="https://cdn.jsdelivr.net/npm/@emailjs/browser@4/dist/build/email.min.js"></script>
```

✅ هذا تم بالفعل في النسخة الجديدة!

---

### ✅ الحل 4: تحميل محلي (بدون إنترنت)
إذا كنت تريد استخدام النظام بدون اتصال إنترنت مستقر:

**الخطوة 1: تحميل المكتبة**
1. اذهب إلى [this link](https://cdn.jsdelivr.net/npm/@emailjs/browser@4/dist/build/email.min.js)
2. احفظ الملف باسم `email.min.js`
3. ضعه في مجلد المشروع `d:\wep\manafed-report-super-main\`

**الخطوة 2: تحديث ملف HTML**
استبدل:
```html
<script src="https://cdn.jsdelivr.net/npm/@emailjs/browser@4/dist/build/email.min.js"></script>
```

بـ:
```html
<script src="email.min.js"></script>
```

---

### ✅ الحل 5: اختبار التحميل
فتح الملف `test-emailjs-loading.html` في المجلد للتحقق من تحميل EmailJS:

1. افتح `test-emailjs-loading.html` في المتصفح
2. انقر على **"تشغيل الاختبار"**
3. سيظهر تقرير كامل عن حالة EmailJS

**النتائج المتوقعة:**
- ✅ EmailJS library loaded
- ✅ All functions available

---

## 🔧 التحقق من الإعدادات في emailjs-notifications.js

**عرّف هذه المتغيرات في ملف `emailjs-notifications.js`:**

```javascript
const EmailJSConfig = {
    serviceID: 'service_skvlwej',              // ✅ موجود
    templateIDLeaveRequest: 'template_leave_request',
    templateIDLeaveApproval: 'template_leave_approval',
    templateIDMedicalReminder: 'template_medical_reminder',
    templateIDWarningIssued: 'template_warning_issued',
    publicKey: 'raY5iQKog8iggJUoY'            // ✅ موجود
};
```

---

## 📋 قائمة التحقق النهائية

- [ ] ✓ إعادة تحميل الصفحة (Ctrl+F5 أو Cmd+Shift+R)
- [ ] ✓ التحقق من اتصال الإنترنت
- [ ] ✓ فتح DevTools وعدم وجود أخطاء حمراء
- [ ] ✓ Network tab يظهر تحميل email.min.js بنجاح
- [ ] ✓ تشغيل test-emailjs-loading.html
- [ ] ✓ تحديث متصفح الويب (قد تكون نسخة قديمة)
- [ ] ✓ تفريغ cache المتصفح (Ctrl+Shift+Delete)

---

## 🔍 أماكن فحصها

### في DevTools Console (F12):
ستجد هذه الرسالة:
```
✅ EmailJS initialized successfully on attempt 1
```

أو:
```
⏳ Waiting for EmailJS to load... (attempt 1/50)
```

### في Network Tab:
ابحث عن:
1. `email.min.js` - يجب أن يكون Status 200
2. `emailjs-notifications.js` - يجب أن يكون Status 200

---

## إذا استمرت المشكلة

**اتبع هذه الخطوات:**

1. **الخطوة 1:** افتح console (F12) وانسخ:
```javascript
typeof window.emailjs
```
يجب أن يظهر: `"object"`

2. **الخطوة 2:** تحقق من initializeEmailJS:
```javascript
typeof initializeEmailJS
```
يجب أن يظهر: `"function"`

3. **الخطوة 3:** جرب التهيئة اليدوية:
```javascript
emailjs.init('raY5iQKog8iggJUoY');
console.log('EmailJS Ready!');
```

4. **الخطوة 4:** إذا حصلت على أي خطأ، انسخ رسالة الخطأ وأرسلها

---

## الحل السريع النهائي

إذا كنت في عجلة من الأمر:

```bash
# 1. افتح hr-management.html
# 2. ابحث عن السطر:
<script src="https://cdn.jsdelivr.net/npm/@emailjs/browser@4/dist/build/email.min.js"></script>

# 3. ضعه قبل هذا السطر:
<script src="emailjs-notifications.js"></script>

# ترتيب صحيح يجب أن يكون:
<script async src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>          ← أولاً
<script src="https://cdn.jsdelivr.net/npm/@emailjs/..."></script>                            ← ثانياً
<script src="custom-alerts.js"></script>                                                     ← ثالثاً
<script src="override-alerts.js"></script>                                                   ← رابعاً
<script src="emailjs-notifications.js"></script>                                             ← خامساً
```

---

## معلومات إضافية

### تفاصيل التحديث:
- ✅ تم إزالة `async` من EmailJS script
- ✅ تم تحسين دالة `initializeEmailJS()`
- ✅ تم إضافة آلية تكرار (retry) لتحميل المكتبة
- ✅ تم إضافة فحوصات في كل دوال الإرسال
- ✅ تم إنشاء ملف اختبار `test-emailjs-loading.html`

### الملفات المعدلة:
- `hr-management.html` - تم إصلاح ترتيب البرامج النصية
- `emailjs-notifications.js` - تم تحسين معالجة الأخطاء
- `test-emailjs-loading.html` - **ملف اختبار جديد**

---

## للمزيد من الدعم

إذا واصلت المشكلة:
1. اختبر باستخدام `test-emailjs-loading.html`
2. انسخ النتائج من سجل الاختبار
3. تحقق من console في DevTools
4. راجع EMAILJS_SETUP_GUIDE.md من جديد
