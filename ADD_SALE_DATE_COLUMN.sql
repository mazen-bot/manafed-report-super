-- ============================================
-- إضافة عمود التاريخ إلى جدول المبيعات
-- Add sale_date column to sales table
-- ============================================

-- 1️⃣ أضف عمود sale_date إذا لم يكن موجوداً
ALTER TABLE public.sales ADD COLUMN IF NOT EXISTS sale_date DATE;

-- 2️⃣ إذا كان لديك عمود created_at، يمكنك نسخ التاريخ منه
UPDATE public.sales 
SET sale_date = CAST(created_at AS DATE) 
WHERE sale_date IS NULL AND created_at IS NOT NULL;

-- 3️⃣ اجعل العمود افتراضياً للتواريخ الجديدة
ALTER TABLE public.sales ALTER COLUMN sale_date SET DEFAULT CURRENT_DATE;

-- 4️⃣ التحقق من أن العمود تم إضافته بنجاح
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'sales' 
AND column_name = 'sale_date';

-- 5️⃣ عرض عدد السجلات التي تم تحديثها
SELECT COUNT(*) as updated_records 
FROM public.sales 
WHERE sale_date IS NOT NULL;
