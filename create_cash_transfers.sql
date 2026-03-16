-- SQL لإنشاء جدول تحويل الكاش بين الفروع في Supabase (Postgres)
-- هذا الجدول مطلوب لمزامنة تحويلات الكاش بين الأجهزة

CREATE TABLE IF NOT EXISTS public.cash_transfers (
    id text PRIMARY KEY,
    from_branch text NOT NULL,
    to_branch text NOT NULL,
    amount numeric(12,2) NOT NULL CHECK (amount > 0),
    transfer_date date NOT NULL,
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- فهرس اختياري لتحسين الفرز الزمني
CREATE INDEX IF NOT EXISTS idx_cash_transfers_updated_at
    ON public.cash_transfers (updated_at DESC);

-- تحديث updated_at تلقائياً عند التعديل
CREATE OR REPLACE FUNCTION public.set_cash_transfers_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_cash_transfers_updated_at ON public.cash_transfers;
CREATE TRIGGER trg_cash_transfers_updated_at
BEFORE UPDATE ON public.cash_transfers
FOR EACH ROW
EXECUTE FUNCTION public.set_cash_transfers_updated_at();

-- ملاحظة: اضبط سياسات RLS حسب سياسة مشروعك قبل الاستخدام في الإنتاج.
