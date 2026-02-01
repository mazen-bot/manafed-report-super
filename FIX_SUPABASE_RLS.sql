-- إذا كنت تواجه خطأ "permission denied" عند الحفظ، جرّب هذا:

-- 1️⃣ تعطيل RLS مؤقتاً (للاختبار فقط)
ALTER TABLE public.sales DISABLE ROW LEVEL SECURITY;

-- 2️⃣ أو إنشاء سياسات RLS سماحة:
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable insert for all" ON public.sales
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable select for all" ON public.sales
  FOR SELECT
  USING (true);

CREATE POLICY "Enable update for all" ON public.sales
  FOR UPDATE
  USING (true);

CREATE POLICY "Enable delete for all" ON public.sales
  FOR DELETE
  USING (true);

-- 3️⃣ التحقق من الأعمدة الموجودة:
-- اذهب إلى SQL Editor > New query وانسخ:
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'sales'
ORDER BY ordinal_position;

-- 4️⃣ إذا كانت الأعمدة الجديدة مفقودة، أضفها:
ALTER TABLE public.sales ADD COLUMN IF NOT EXISTS visa_sales numeric;
ALTER TABLE public.sales ADD COLUMN IF NOT EXISTS master_sales numeric;
ALTER TABLE public.sales ADD COLUMN IF NOT EXISTS mada_sales numeric;
