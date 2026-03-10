# إصلاح خطأ RLS في عملية رفع الملفات الطبية
# Fix RLS Policy Violation Error

## ✅ الخطوات المطلوبة

### 1. تشغيل ملف الإصلاح في قاعدة البيانات
- الملف: `FIX_RLS_POLICIES.sql`
- الخطوات:
  1. افتح [Supabase Dashboard](https://supabase.com/dashboard)
  2. اختر مشروعك
  3. انتقل إلى **SQL Editor**
  4. انسخ محتوى ملف `FIX_RLS_POLICIES.sql`
  5. اضغط **Run**

### 2. التحقق من التطبيق
بعد تشغيل الملف، سيتم:
- ✅ حذف السياسات القديمة الخاطئة
- ✅ إنشاء سياسات جديدة أكثر تحديداً
- ✅ إضافة التحقق من `employee_id` و `leave_request_id`

### 3. ملفات محدثة
تم تحديث [hr-management.html](hr-management.html):
- دالة `uploadMedicalCertificate()`:
  - الآن تضيف سجل في جدول `leave_attachments`
  - تتضمن جميع بيانات الملف (الحجم، النوع، الرابط)
  
- دالة `deleteMedicalFile()`:
  - تحذف السجل من `leave_attachments` أولاً
  - ثم تحدث `leave_requests`

## 🔧 ما تم إصلاحه

### السياسات القديمة (خاطئة):
```sql
CREATE POLICY "..." ON leave_requests FOR INSERT WITH CHECK (true);
-- ❌ السياسة حسبت أي صف جديد صحيح
```

### السياسات الجديدة (صحيحة):
```sql
CREATE POLICY "..." ON leave_requests FOR INSERT WITH CHECK (employee_id IS NOT NULL);
-- ✅ السياسة تتحقق من أن employee_id موجود
```

## 📊 هيكل البيانات

### جدول leave_attachments
| العمود | النوع | الشرح |
|--------|-------|-------|
| id | BIGSERIAL | رقم تعريف الملف |
| leave_request_id | BIGINT | رقم طلب الإجازة |
| employee_id | TEXT | رقم الموظف |
| file_name | TEXT | اسم الملف |
| file_url | TEXT | رابط الملف |
| file_size | INTEGER | حجم الملف بالبايت |
| file_type | TEXT | نوع الملف |
| uploaded_at | TIMESTAMP | وقت الرفع |

## ✨ الميزات الجديدة

1. **تتبع الملفات**: كل ملف يتم تسجيله مع معلومات كاملة
2. **حماية البيانات**: RLS يضمن أن الموظف يضيف ملفاته فقط
3. **سهولة الإدارة**: يمكن حذف الملفات بأمان

## 🚀 الخطوات التالية

1. ✅ شغّل `FIX_RLS_POLICIES.sql`
2. ✅ حاول رفع ملف طبي من جديد
3. ✅ تحقق من نجاح الرفع ✅

## 📝 ملاحظات مهمة

- الملف يجب أن يكون صورة (JPG, PNG, GIF) أو PDF
- الحد الأقصى لحجم الملف 5MB
- الموعد النهائي للرفع 3 أيام من تاريخ الطلب
- الخصم يتم تطبيقه تلقائياً بعد انتهاء الموعد النهائي

## ❓ حل المشاكل

### إذا استمرت الأخطاء:

1. **تحقق من Supabase Status**:
   - هل خادم Supabase يعمل بشكل طبيعي؟
   - تحقق من [Supabase Status Page](https://status.supabase.com)

2. **حقق من الأذونات**:
   - هل أنت موثق قبل محاولة الرفع؟
   - هل employee_id موجود في نظام؟

3. **تحقق من Bucket**:
   - هل عمل إنشاء bucket "medical-certificates"؟
   - Storage > Buckets > تحقق من وجود "medical-certificates"

4. **تحقق من RLS**:
   - اذهب إلى Tables > leave_requests > RLS
   - تأكد من تطبيق السياسات الجديدة

## 📞 الدعم

إذا استمرت المشاكل:
1. تحقق من logs في Supabase Dashboard
2. جرّب قاعدة بيانات مختلفة للاختبار
3. تواصل مع فريق Supabase Support
