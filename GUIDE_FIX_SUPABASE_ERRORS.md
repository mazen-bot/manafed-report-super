# 🔧 دليل حل مشاكل الحفظ في Supabase

## ✅ الخطوات الأولى للتشخيص

### 1. افتح Console (أدوات المطور)
```
Windows: Ctrl + Shift + I أو F12
Mac: Cmd + Option + I
```

### 2. انتقل إلى تبويب Console

### 3. جرّب الحفظ مرة أخرى وابحث عن الأخطاء

---

## 🔍 أنواع الأخطاء الشائعة والحلول

### ❌ خطأ: `undefined is not a function`
**السبب**: المتغيرات لم تُحمّل بشكل صحيح
**الحل**:
- أعد تحميل الصفحة: `Ctrl + F5` (تحميل القسري)
- امسح ذاكرة التخزين المؤقت (Cache)

---

### ❌ خطأ: `Permission denied for schema public`
**السبب**: سياسات RLS تمنع الكتابة
**الحل**:
1. اذهب إلى [Supabase Dashboard](https://app.supabase.com)
2. اختر مشروعك
3. اذهب إلى **SQL Editor**
4. اختر **New query**
5. انسخ والصق هذا الكود:
```sql
ALTER TABLE public.sales DISABLE ROW LEVEL SECURITY;
```
6. اضغط **Run**

> ⚠️ **ملاحظة**: هذا يعطّل الأمان مؤقتاً. بعد الاختبار، أعد تفعيله بسياسات آمنة.

---

### ❌ خطأ: `column "sale_date" does not exist`
**السبب**: اسم الحقل خاطئ أو الحقل غير موجود
**الحل**:
1. اذهب إلى Supabase Dashboard
2. اختر **Sales** table
3. تحقق من أسماء الأعمدة في **Structure** tab
4. اتأكد أنها بهذا الشكل (snake_case):
   - `employee_id` ✅
   - `branch` ✅
   - `sale_date` ✅
   - `total_sales` ✅
   - `total_cash` ✅
   - `total_card` ✅
   - `visa_sales` ✅
   - `master_sales` ✅
   - `mada_sales` ✅

---

### ❌ خطأ: `connection refused`
**السبب**: مشكلة في الاتصال بـ Supabase
**الحل**:
1. تحقق من اتصال الإنترنت
2. تحقق من أن Supabase URL صحيحة
3. تحقق من أن API Key صحيحة

---

## 📝 التحقق من أسماء الأعمدة

أنسخ هذا الكود في SQL Editor:

```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'sales'
ORDER BY ordinal_position;
```

يجب أن ترى:
```
employee_id    | character varying | NO
branch         | character varying | NO
sale_date      | date              | NO
total_sales    | numeric           | NO
total_cash     | numeric           | NO
total_card     | numeric           | NO
visa_sales     | numeric           | YES
master_sales   | numeric           | YES
mada_sales     | numeric           | YES
tamara         | numeric           | YES
tabby          | numeric           | YES
extra_cash     | numeric           | YES
expenses       | numeric           | YES
returns        | numeric           | YES
withdrawal     | numeric           | YES
notes          | text              | YES
financing_notes| text              | YES
attachment     | text              | YES
created_at     | timestamp         | NO
```

---

## 🛠️ إنشاء الجدول من الصفر (إذا كان معطوباً)

```sql
-- حذف الجدول القديم (حذر: سيؤدي لفقدان البيانات!)
DROP TABLE IF EXISTS public.sales;

-- إنشاء جدول جديد
CREATE TABLE public.sales (
  id bigint primary key generated always as identity,
  employee_id character varying not null,
  branch character varying not null,
  sale_date date not null,
  total_sales numeric not null,
  total_cash numeric not null,
  total_card numeric not null,
  visa_sales numeric default 0,
  master_sales numeric default 0,
  mada_sales numeric default 0,
  tamara numeric default 0,
  tabby numeric default 0,
  extra_cash numeric default 0,
  expenses numeric default 0,
  returns numeric default 0,
  withdrawal numeric default 0,
  notes text,
  financing_notes text,
  attachment text,
  created_at timestamp with time zone default now()
);

-- تعطيل RLS (يمكن تفعيله لاحقاً بسياسات آمنة)
ALTER TABLE public.sales DISABLE ROW LEVEL SECURITY;

-- منح الصلاحيات
GRANT ALL PRIVILEGES ON public.sales TO anon;
GRANT ALL PRIVILEGES ON public.sales TO authenticated;
```

---

## 🧪 اختبار الحفظ يدويّاً

انسخ هذا في Console:

```javascript
// اختبر الاتصال
const testData = {
  employee_id: 'TEST001',
  branch: 'الفرع الرئيسي',
  sale_date: new Date().toISOString().split('T')[0],
  total_sales: 1000,
  total_cash: 500,
  total_card: 500,
  tamara: 0,
  tabby: 0,
  extra_cash: 0,
  expenses: 0,
  returns: 0,
  withdrawal: 0,
  notes: 'test',
  financing_notes: '-',
  attachment: '-'
};

supabase
  .from('sales')
  .insert([testData])
  .then(result => {
    console.log('✅ النتيجة:', result);
    if (result.error) {
      console.error('❌ الخطأ:', result.error);
    } else {
      console.log('✅ تم الحفظ بنجاح!');
    }
  })
  .catch(err => console.error('❌ الاستثناء:', err));
```

---

## 💾 إذا استمرت المشكلة

انسخ واشارك:

1. **الخطأ من Console** (Ctrl+Shift+I → Console)
2. **أسماء الأعمدة** (من SQL Editor query أعلاه)
3. **لقطة شاشة** من Supabase Dashboard (SQL tab)
