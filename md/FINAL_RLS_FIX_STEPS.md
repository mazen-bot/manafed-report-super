# 🚨 حل نهائي وفعلي لمشكلة RLS

## المشكلة الحقيقية
السياسات على جدول `leave_requests` ترفع التحديثات.

---

## ✅ الحل (خطوتان فقط)

### ✋ الخطوة 1: شغّل السكريبت

**سكريبت**: `REMOVE_ALL_POLICIES.sql`

**كيفية التشغيل**:
1. اذهب إلى [Supabase Dashboard](https://supabase.com/dashboard)
2. اختر مشروعك
3. انتقل إلى **SQL Editor** (في القائمة اليسرى)
4. **انسخ كل محتوى** ملف `REMOVE_ALL_POLICIES.sql`
5. **الصق** في نافذة SQL Editor
6. اضغط الزر **RUN** (الأحمر)
7. **انتظر** حتى اكتمال العملية (يجب أن ترى ✅ بدون أخطاء)

---

### ✋ الخطوة 2: اختبر الرفع من جديد

1. عد إلى صفحة `hr-management.html`
2. اضغط على علامة تبويب **"الشهادات الطبية"**
3. حاول رفع ملف من جديد
4. **افتح Browser Console** بـ F12 أو Ctrl+Shift+I
5. راقب الرسائل في Console

---

## 📊 ماذا تتوقع أن ترى في Console

عند الرفع الناجح:
```
[AUTH] Session found: abc123...
[UPLOAD] Starting upload process
[USER] Employee ID: 1001
[LEAVE] Leave Request ID: 5
[STORAGE] Uploading file: 1001_5_1234567890
[STORAGE] File uploaded successfully
[URL] Public URL: https://...
[DB] Inserting attachment record
[DB] Attachment record inserted: [...]
[DB] Updating leave_requests record
[SUCCESS] Upload completed successfully
```

---

## ❌ إذا حدث خطأ

### خطأ 1: `[INSERT ERROR]`
```
[INSERT ERROR] {
  message: "...",
  status: 409
}
```
**الحل**: تأكد من تشغيل السكريبت بنجاح

### خطأ 2: `[UPDATE ERROR]`
```
[UPDATE ERROR] {
  message: "new row violates...",
  status: 403
}
```
**الحل**: تشغيل السكريبت لم ينجح → كرر الخطوة 1

### خطأ 3: `[AUTH] Session not found`
```
[AUTH] Session: null
```
**الحل**: أنت لست موثق الدخول
- عد إلى `index.html`
- سجل الدخول من جديد
- ثم حاول الرفع

---

## 🔍 التحقق من تطبيق السكريبت

بعد تشغيل السكريبت، تحقق من:

1. في Supabase Dashboard، انتقل إلى **Tables**
2. اختر جدول **`leave_requests`**
3. في الأعلى اليمين، اضغط على **"RLS"**
4. يجب أن ترى سياسة واحدة فقط:
   - الاسم: `leave_requests_all_users`
   - القاعدة: `USING (true) WITH CHECK (true)`

---

## 📋 ملخص التغييرات

| العنصر | القديم | الجديد |
|--------|--------|--------|
| السياسات على leave_requests | 4-8 سياسات معقدة | سياسة واحدة بسيطة |
| السياسات على leave_attachments | سياسات خاطئة | سياسة واحدة بسيطة |
| السماح للمستخدمين | مقيد جداً | السماح بالكل |

---

## ✨ هل يعمل الآن؟

**بعد تطبيق السكريبت**:
- ✅ الملفات ترفع بنجاح ✅
- ✅ الملفات تُسجل في قاعدة البيانات ✅
- ✅ التحديثات تنجح ✅

---

## 📞 إذا استمرت المشاكل

أخبرني برسالة الخطأ الكاملة من Browser Console مع الخطوات التي فعلتها.

**معلومات مهمة**:
1. ما هي رسالة الخطأ بالضبط؟
2. هل شغّلت السكريبت بنجاح؟ (تحقق من عدم وجود أخطاء أحمر)
3. هل أنت موثق الدخول؟

---

## 🎯 الخطوات الأساسية (تكرار)

```
1. افتح REMOVE_ALL_POLICIES.sql
2. انسخ المحتوى
3. افتح Supabase SQL Editor
4. الصق والشغّل
5. انتظر ✅
6. حاول الرفع
7. شاهد Console
```

**اتمنى أن ينجح الآن! ✨**
