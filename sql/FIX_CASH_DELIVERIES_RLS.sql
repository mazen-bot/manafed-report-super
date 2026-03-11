-- إصلاح سياسات RLS لجدول cash_deliveries
-- شغّل هذا الملف داخل Supabase SQL Editor

BEGIN;

-- تأكد من وجود الجدول
CREATE TABLE IF NOT EXISTS public.cash_deliveries (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    branch text NOT NULL,
    recipient text NOT NULL,
    delivered_amount numeric(12,2) NOT NULL,
    delivered_at date NOT NULL,
    proof text,
    created_at timestamptz DEFAULT now()
);

-- منح الصلاحيات الأساسية للأدوار المستخدمة من الواجهة
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.cash_deliveries TO anon, authenticated;

-- إزالة السياسات القديمة المتضاربة إن وجدت
DROP POLICY IF EXISTS "cash_deliveries_select_anon" ON public.cash_deliveries;
DROP POLICY IF EXISTS "cash_deliveries_insert_anon" ON public.cash_deliveries;
DROP POLICY IF EXISTS "cash_deliveries_update_anon" ON public.cash_deliveries;
DROP POLICY IF EXISTS "cash_deliveries_delete_anon" ON public.cash_deliveries;
DROP POLICY IF EXISTS "cash_deliveries_select_authenticated" ON public.cash_deliveries;
DROP POLICY IF EXISTS "cash_deliveries_insert_authenticated" ON public.cash_deliveries;
DROP POLICY IF EXISTS "cash_deliveries_update_authenticated" ON public.cash_deliveries;
DROP POLICY IF EXISTS "cash_deliveries_delete_authenticated" ON public.cash_deliveries;
DROP POLICY IF EXISTS "Enable select for all on cash_deliveries" ON public.cash_deliveries;
DROP POLICY IF EXISTS "Enable insert for all on cash_deliveries" ON public.cash_deliveries;
DROP POLICY IF EXISTS "Enable update for all on cash_deliveries" ON public.cash_deliveries;
DROP POLICY IF EXISTS "Enable delete for all on cash_deliveries" ON public.cash_deliveries;
DROP POLICY IF EXISTS "Allow public read cash_deliveries" ON public.cash_deliveries;
DROP POLICY IF EXISTS "Allow public insert cash_deliveries" ON public.cash_deliveries;
DROP POLICY IF EXISTS "Allow public update cash_deliveries" ON public.cash_deliveries;
DROP POLICY IF EXISTS "Allow public delete cash_deliveries" ON public.cash_deliveries;

-- تفعيل RLS
ALTER TABLE public.cash_deliveries ENABLE ROW LEVEL SECURITY;

-- سياسات متوافقة مع الواجهة الحالية
CREATE POLICY "cash_deliveries_select_anon"
ON public.cash_deliveries
FOR SELECT
TO anon
USING (true);

CREATE POLICY "cash_deliveries_insert_anon"
ON public.cash_deliveries
FOR INSERT
TO anon
WITH CHECK (
    branch IS NOT NULL
    AND recipient IS NOT NULL
    AND delivered_amount IS NOT NULL
    AND delivered_at IS NOT NULL
);

CREATE POLICY "cash_deliveries_update_anon"
ON public.cash_deliveries
FOR UPDATE
TO anon
USING (true)
WITH CHECK (
    branch IS NOT NULL
    AND recipient IS NOT NULL
    AND delivered_amount IS NOT NULL
    AND delivered_at IS NOT NULL
);

CREATE POLICY "cash_deliveries_delete_anon"
ON public.cash_deliveries
FOR DELETE
TO anon
USING (true);

CREATE POLICY "cash_deliveries_select_authenticated"
ON public.cash_deliveries
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "cash_deliveries_insert_authenticated"
ON public.cash_deliveries
FOR INSERT
TO authenticated
WITH CHECK (
    branch IS NOT NULL
    AND recipient IS NOT NULL
    AND delivered_amount IS NOT NULL
    AND delivered_at IS NOT NULL
);

CREATE POLICY "cash_deliveries_update_authenticated"
ON public.cash_deliveries
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (
    branch IS NOT NULL
    AND recipient IS NOT NULL
    AND delivered_amount IS NOT NULL
    AND delivered_at IS NOT NULL
);

CREATE POLICY "cash_deliveries_delete_authenticated"
ON public.cash_deliveries
FOR DELETE
TO authenticated
USING (true);

COMMIT;

-- تحقق سريع بعد التنفيذ
SELECT schemaname, tablename, policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'cash_deliveries'
ORDER BY cmd, policyname;