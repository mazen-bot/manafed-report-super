# حل مشكلة RLS - نسخة completاً
# Complete RLS Fix Guide

## 🚨 المشكلة
```
فشل رفع الملف: new row violates row-level security policy
```

هذا الخطأ يعني أن قاعدة البيانات ترفض إدراج الملف لأسباب أمان تتعلق بـ RLS.

---

## ✅ الحل الشامل (4 خطوات)

### الخطوة 1️⃣: تشغيل سكريبت إعادة البناء

**الملف**: `REBUILD_ATTACHMENTS_TABLE.sql`

**الخطوات**:
1. افتح [Supabase Dashboard](https://supabase.com/dashboard)
2. انتقل إلى **SQL Editor**
3. **انسخ** محتوى الملف `REBUILD_ATTACHMENTS_TABLE.sql` بالكامل
4. **الصق** في SQL Editor
5. اضغط **RUN** (الزر الأحمر)
6. **انتظر** حتى اكتمال العملية ✅

⚠️ **تنبيه**: هذا السكريبت يحذف الجدول القديم ويعيد إنشاء جديد صحيح

---

### الخطوة 2️⃣: تحقق من أن الجدول تم إنشاؤه

في Supabase Dashboard:
1. انتقل إلى **Tables** في الجانب الأيسر
2. ابحث عن **`leave_attachments`**
3. تحقق من وجوده في القائمة ✅

---

### الخطوة 3️⃣: اختبر الرفع

1. افتح صفحة `hr-management.html`
2. انتقل إلى **علامة تبويب الشهادات الطبية**
3. حاول رفع ملف من جديد
4. **افتح Browser Console** (F12 أو اضغط Ctrl+Shift+I)
5. ستجد رسائل `[DEBUG]` تظهر ما يحدث

---

### الخطوة 4️⃣: اقرأ رسائل التصحيح

عندما تحاول الرفع، ستجد في Console:
```
[DEBUG] Uploading file: {
  fileName: "...",
  fileSize: 123456,
  fileType: "image/jpeg",
  employeeId: "123",
  leaveRequestId: 1
}

[DEBUG] File uploaded, now inserting to database

[DEBUG] Inserting attachment record: {...}

[DEBUG] Record inserted successfully: [...]
```

إذا رأيت هذه الرسائل **بدون أخطاء** ✅ = النظام يعمل

إذا رأيت **خطأ** اقرأ رسالة الخطأ وأخبرني بها.

---

## 📋 ملاحظات تقنية مهمة

### الفرق بين السكريبتات:

| الملف | الغرض | الحالة |
|------|-------|--------|
| `add_medical_certificate_fields.sql` | إضافة أعمدة وجدول | ✅ قديم (لا تشغله) |
| `FIX_RLS_POLICIES.sql` | محاولة إصلاح السياسات | ⚠️ لم ينجح |
| `REBUILD_ATTACHMENTS_TABLE.sql` | **إعادة بناء كاملة** | ✅ **الحل الفعلي** |

### ما يفعله السكريبت الجديد:

1. ✅ **يحذف** الجدول القديم الــِ مشاكل
2. ✅ **ينشئ** جدول جديد نظيف
3. ✅ **يضيف** سياسة RLS بسيطة وفعالة
4. ✅ **يفعّل** جميع الفهارس

---

## 🔍 إذا استمرت المشاكل

### 1. تحقق من Employee ID
في Browser Console، اكتب:
```javascript
console.log('Current User:', currentUser);
```
يجب أن ترى:
```
Current User: {
  employee_id: "123",
  name: "محمد",
  email: "...",
  ...
}
```

إذا كان `employee_id` فارغ = **المشكلة هنا**

### 2. تحقق من Bucket
في Supabase Dashboard:
- Storage > Buckets
- تأكد من وجود **`medical-certificates`**

### 3. تحقق من Authentication
هل أنت **موثق الدخول** قبل محاولة الرفع؟
- اذهب لصفحة `index.html` وتأكد من تسجيل الدخول

### 4. تحقق من RLS Status
في Supabase Dashboard:
- Tables > leave_attachments
- انقر على **RLS** في الزاوية العلوية اليمنى
- تأكد أنه **مفعّل** (أخضر)

---

## 📞 معلومات التصحيح

**إذا استمرت المشاكل، أخبرني بـ:**

1. رسالة الخطأ الكاملة من Browser Console
2. ماذا ترى عندما تكتب في Console:
   ```javascript
   console.log(currentUser.employee_id);
   ```
3. هل الملف يرفع إلى Storage بنجاح؟ (تحقق من Storage > medical-certificates)

---

## ✨ الخطوات السريعة

**اختصار**:
1. شغّل `REBUILD_ATTACHMENTS_TABLE.sql` ← **هذه هي الخطوة الوحيدة المهمة**
2. افتح Browser Console (F12)
3. حاول رفع ملف
4. اقرأ رسائل `[DEBUG]` في Console
5. أخبرني بأي أخطاء

---

**🎯 النتيجة المتوقعة**: ✅ سيتم رفع الملف بنجاح بعد هذه الخطوات
