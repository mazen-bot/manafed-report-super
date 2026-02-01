# 📦 إعداد Supabase Storage لرفع الصور

## الخطوات المطلوبة

### 1️⃣ إنشاء Bucket في Supabase

1. افتح لوحة تحكم Supabase: [https://app.supabase.com](https://app.supabase.com)
2. اختر مشروعك
3. من القائمة الجانبية، اضغط على **Storage**
4. اضغط زر **"New bucket"**
5. أدخل البيانات التالية:
   - **Name**: `sales-attachments`
   - **Public bucket**: ✅ فعّل هذا الخيار (لعرض الصور)
6. اضغط **"Create bucket"**

---

### 2️⃣ إعداد سياسات الوصول (RLS Policies)

بعد إنشاء الـ bucket، نحتاج لتفعيل سياسات تسمح برفع وقراءة الصور:

#### الطريقة 1: عبر واجهة Storage (سريعة)

1. في صفحة Storage، اضغط على bucket **sales-attachments**
2. اذهب لتبويب **Policies**
3. اضغط **"New Policy"**
4. اختر **"Allow public access"** أو **"Custom policy"**

#### الطريقة 2: عبر SQL Editor (موصى بها)

افتح **SQL Editor** ونفّذ الأوامر التالية:

```sql
-- السماح للجميع برفع الصور
CREATE POLICY "Allow public uploads"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'sales-attachments');

-- السماح للجميع بقراءة الصور
CREATE POLICY "Allow public reads"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'sales-attachments');

-- السماح للجميع بتحديث الصور (اختياري)
CREATE POLICY "Allow public updates"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'sales-attachments');

-- السماح للجميع بحذف الصور (اختياري)
CREATE POLICY "Allow public deletes"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'sales-attachments');
```

---

### 3️⃣ التحقق من الإعداد

#### اختبار رفع صورة من Console:

افتح Console في المتصفح (F12) على صفحة index.html وجرّب:

```javascript
// اختبار رفع ملف تجريبي
const testFile = new File(['test'], 'test.txt', { type: 'text/plain' });

const { data, error } = await supabase.storage
    .from('sales-attachments')
    .upload('test-folder/test.txt', testFile);

console.log('Upload result:', { data, error });
```

**النتيجة المتوقعة:**
- ✅ إذا نجح: `data` يحتوي على `path: "test-folder/test.txt"`
- ❌ إذا فشل: `error` يحتوي على وصف الخطأ

---

### 4️⃣ الحصول على رابط الصورة

بعد رفع الصورة بنجاح، يمكنك الحصول على الرابط العام:

```javascript
const { data: urlData } = supabase.storage
    .from('sales-attachments')
    .getPublicUrl('test-folder/test.txt');

console.log('Public URL:', urlData.publicUrl);
```

---

## 🔧 استكشاف الأخطاء

### ❌ خطأ: "new row violates row-level security policy"

**السبب:** سياسات RLS غير مفعّلة

**الحل:**
```sql
-- تحقق من السياسات الموجودة
SELECT * FROM pg_policies WHERE tablename = 'objects';

-- إذا لم تظهر سياسات، نفذ الأوامر في الخطوة 2
```

---

### ❌ خطأ: "Bucket not found"

**السبب:** اسم الـ bucket خاطئ أو غير موجود

**الحل:**
1. تأكد من اسم الـ bucket: `sales-attachments`
2. تحقق من القائمة في Storage → Buckets

---

### ❌ خطأ: "The resource already exists"

**السبب:** الملف موجود بالفعل بنفس الاسم

**الحل:**
- استخدم أسماء فريدة للملفات (الكود الحالي يستخدم timestamp + random)
- أو استخدم `upsert: true` لاستبدال الملف

---

## ✅ التحقق النهائي

بعد تطبيق الخطوات:

1. ✅ Bucket اسمه `sales-attachments` موجود
2. ✅ Bucket عام (Public)
3. ✅ سياسات RLS مفعّلة للرفع والقراءة
4. ✅ الكود في index.html جاهز للاستخدام

---

## 📝 ملاحظات هامة

- **الحجم الأقصى للصورة:** 5MB (يمكن تعديله من الكود)
- **الصيغ المدعومة:** JPG, PNG, GIF, WEBP
- **مسار التخزين:** `sales-images/{timestamp}_{random}.{ext}`
- **الرابط المحفوظ في قاعدة البيانات:** رابط عام كامل يمكن الوصول له مباشرة

---

## 🎯 استخدام الميزة

بعد إتمام الإعداد:

1. افتح صفحة index.html
2. سجّل الدخول كموظف
3. اختر صورة من جهازك (زر "📸 رفع صورة")
4. املأ باقي البيانات
5. اضغط "حفظ"
6. ✅ سيتم رفع الصورة تلقائياً وحفظ رابطها في قاعدة البيانات

---

## 🔗 عرض الصور في التقارير

الصور مرفوعة ورابطها محفوظ في حقل `attachment` في جدول `sales`.

لعرضها في صفحة التقارير (reports.html)، يمكن استخدام:

```javascript
function getAttachmentCell(record) {
    if (record.attachment && record.attachment !== '-' && record.attachment.startsWith('http')) {
        return `<a href="${record.attachment}" target="_blank" style="color:#4caf50;">🖼️ عرض الصورة</a>`;
    }
    return 'لا يوجد';
}
```

---

**تم التحديث:** فبراير 2026
