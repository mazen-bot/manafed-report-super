-- 🚨 إصلاح عاجل: عمود saleDate غير موجود
-- URGENT FIX: saleDate column not found

-- نسخ هذه الأوامر وتنفيذها في Supabase SQL Editor:

-- 1️⃣ إضافة العمود
ALTER TABLE sales ADD COLUMN IF NOT EXISTS "saleDate" DATE;

-- 2️⃣ نسخ القيم من sale_date إن وجد
UPDATE sales SET "saleDate" = sale_date WHERE sale_date IS NOT NULL AND "saleDate" IS NULL;

-- 3️⃣ تعيين تاريخ اليوم للسجلات الفارغة
UPDATE sales SET "saleDate" = CURRENT_DATE WHERE "saleDate" IS NULL;

-- ✅ تم! أعد تحميل صفحة reports.html
