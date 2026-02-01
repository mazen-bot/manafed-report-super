-- ✅ أضف هذه الأعمدة الناقصة إلى جدول sales

-- شغّل هذا الأمر في Supabase SQL Editor:

ALTER TABLE public.sales ADD COLUMN IF NOT EXISTS visa_sales numeric DEFAULT 0;
ALTER TABLE public.sales ADD COLUMN IF NOT EXISTS master_sales numeric DEFAULT 0;
ALTER TABLE public.sales ADD COLUMN IF NOT EXISTS mada_sales numeric DEFAULT 0;

-- التحقق من أن الأعمدة تمت إضافتها:
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'sales' 
AND column_name IN ('visa_sales', 'master_sales', 'mada_sales')
ORDER BY ordinal_position;
