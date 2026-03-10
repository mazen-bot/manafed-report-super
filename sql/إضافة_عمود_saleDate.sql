-- ===================================
-- إصلاح خطأ: عمود saleDate غير موجود
-- Fix: saleDate column not found error
-- ===================================

-- الخطوة 1: التحقق من الأعمدة الموجودة حالياً
-- Step 1: Check existing columns
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'sales'
AND column_name LIKE '%date%'
ORDER BY ordinal_position;

-- الخطوة 2: إضافة عمود saleDate إذا لم يكن موجوداً
-- Step 2: Add saleDate column if it doesn't exist
ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS "saleDate" DATE;

-- الخطوة 3: إذا كان لديك عمود sale_date، انسخ القيم إلى saleDate
-- Step 3: If you have sale_date column, copy values to saleDate
DO $$ 
BEGIN
    -- Check if sale_date column exists
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'sales' 
        AND column_name = 'sale_date'
    ) THEN
        -- Copy data from sale_date to saleDate
        UPDATE sales 
        SET "saleDate" = sale_date 
        WHERE "saleDate" IS NULL AND sale_date IS NOT NULL;
        
        RAISE NOTICE 'تم نسخ البيانات من sale_date إلى saleDate';
    ELSE
        RAISE NOTICE 'عمود sale_date غير موجود، لا حاجة للنسخ';
    END IF;
END $$;

-- الخطوة 4: إذا كان saleDate فارغاً، استخدم تاريخ اليوم كقيمة افتراضية
-- Step 4: If saleDate is empty, use current date as default
UPDATE sales 
SET "saleDate" = CURRENT_DATE 
WHERE "saleDate" IS NULL;

-- الخطوة 5: التحقق من النتيجة
-- Step 5: Verify the result
SELECT 
    COUNT(*) as total_records,
    COUNT("saleDate") as records_with_date,
    COUNT(DISTINCT "saleDate") as unique_dates
FROM sales;

-- عرض بعض السجلات للتحقق
SELECT 
    id,
    branch,
    "employeeName",
    "saleDate",
    sales,
    created_at
FROM sales
ORDER BY created_at DESC
LIMIT 5;

-- ===================================
-- ملاحظات مهمة
-- Important Notes
-- ===================================
/*
📋 الشرح:
   - PostgreSQL/Supabase يفضل استخدام snake_case للأعمدة
   - لكن الكود JavaScript يستخدم camelCase
   - يجب وضع أسماء الأعمدة بـ camelCase بين علامات اقتباس مزدوجة

⚠️ حالات محتملة:
   1. إذا كان العمود موجود باسم sale_date:
      - سيتم إنشاء عمود saleDate جديد
      - سيتم نسخ البيانات من sale_date إلى saleDate
   
   2. إذا لم يكن أي عمود تاريخ موجود:
      - سيتم إنشاء saleDate
      - سيتم ملؤه بتاريخ اليوم للسجلات الحالية

   3. إذا كان saleDate موجود بالفعل:
      - لن يحدث شيء (ADD COLUMN IF NOT EXISTS)

✅ بعد تنفيذ هذا السكريبت:
   - أعد تحميل صفحة reports.html
   - جرّب تحديث التاريخ مرة أخرى
   - يجب أن يعمل بدون أخطاء

🔄 بديل: تحديث الكود بدلاً من قاعدة البيانات
   إذا كنت تفضل تعديل الكود بدلاً من قاعدة البيانات:
   - افتح reports.html
   - استبدل جميع 'saleDate' بـ 'sale_date'
   - (لكن هذا يتطلب تعديل مئات الأسطر)
*/
