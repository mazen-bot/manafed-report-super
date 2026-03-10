-- إضافة عمود الملاحظات العامة إلى جدول المبيعات
ALTER TABLE sales
ADD COLUMN IF NOT EXISTS general_notes TEXT;