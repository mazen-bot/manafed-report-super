-- SQL لإنشاء جدول cash_deliveries في قاعدة Supabase (Postgres)
-- تأكد من ضبط أسماء الأعمدة حسب حاجتك

CREATE TABLE IF NOT EXISTS public.cash_deliveries (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    branch text NOT NULL,
    recipient text NOT NULL,
    delivered_amount numeric(12,2) NOT NULL,
    delivered_at date NOT NULL,
    proof text,
    created_at timestamptz DEFAULT now()
);

-- مثال على منح صلاحيات للـ anon (اختياري - راجع سياسات RLS في Supabase)
-- GRANT SELECT, INSERT ON public.cash_deliveries TO anon;
