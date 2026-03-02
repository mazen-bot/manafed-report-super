-- ===================================
-- إصلاح سريع لمشكلة تحديث التاريخ
-- Quick Fix for Date Update Issue
-- ===================================

-- الخطوة 1: التحقق من حالة RLS الحالية
-- Step 1: Check current RLS status
SELECT 
    schemaname,
    tablename, 
    policyname, 
    permissive, 
    cmd
FROM pg_policies 
WHERE tablename = 'sales'
ORDER BY policyname;

-- الخطوة 2: التأكد من تفعيل RLS
-- Step 2: Enable RLS on sales table
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;

-- الخطوة 3: حذف السياسات القديمة للتحديث
-- Step 3: Drop old update policies
DROP POLICY IF EXISTS "Allow public update sales" ON sales;
DROP POLICY IF EXISTS "Enable update for all" ON sales;
DROP POLICY IF EXISTS "Users can update sales" ON sales;

-- الخطوة 4: إنشاء سياسة تحديث جديدة وشاملة
-- Step 4: Create new comprehensive update policy
CREATE POLICY "Allow public update sales" 
ON sales 
FOR UPDATE 
USING (true)  -- يسمح بتحديث أي سجل
WITH CHECK (true);  -- يسمح بأي قيمة جديدة

-- الخطوة 5: التأكد من وجود سياسات القراءة والإدراج والحذف
-- Step 5: Ensure read, insert, and delete policies exist

-- سياسة القراءة
DROP POLICY IF EXISTS "Allow public read sales" ON sales;
CREATE POLICY "Allow public read sales" 
ON sales 
FOR SELECT 
USING (true);

-- سياسة الإدراج
DROP POLICY IF EXISTS "Allow public insert sales" ON sales;
CREATE POLICY "Allow public insert sales" 
ON sales 
FOR INSERT 
WITH CHECK (true);

-- سياسة الحذف
DROP POLICY IF EXISTS "Allow public delete sales" ON sales;
CREATE POLICY "Allow public delete sales" 
ON sales 
FOR DELETE 
USING (true);

-- الخطوة 6: التحقق من العمود saleDate
-- Step 6: Verify saleDate column exists
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'sales' 
AND column_name IN ('saleDate', 'sale_date', 'date');

-- إضافة عمود saleDate إذا لم يكن موجوداً
-- Add saleDate column if it doesn't exist
ALTER TABLE sales ADD COLUMN IF NOT EXISTS "saleDate" DATE;

-- إذا كان لديك عمود sale_date، انسخ القيم
-- If you have sale_date column, copy values
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'sales' AND column_name = 'sale_date'
    ) THEN
        UPDATE sales SET "saleDate" = sale_date 
        WHERE "saleDate" IS NULL AND sale_date IS NOT NULL;
    END IF;
END $$;

-- تعيين تاريخ اليوم للسجلات التي ليس لها تاريخ
-- Set today's date for records without a date
UPDATE sales SET "saleDate" = CURRENT_DATE WHERE "saleDate" IS NULL;

-- الخطوة 7: اختبار التحديث
-- Step 7: Test update (استبدل القيم بقيم حقيقية من جدولك)
-- Replace with actual values from your table
/*
UPDATE sales 
SET saleDate = '2026-03-02'
WHERE id = 'YOUR_ACTUAL_RECORD_ID'
RETURNING *;
*/

-- الخطوة 8: التحقق النهائي - عرض جميع السياسات
-- Step 8: Final verification - show all policies
SELECT 
    schemaname,
    tablename, 
    policyname, 
    permissive, 
    roles, 
    cmd,
    CASE 
        WHEN qual = 'true' THEN '✅ متاح للجميع'
        ELSE qual 
    END as using_clause,
    CASE 
        WHEN with_check = 'true' THEN '✅ متاح للجميع'
        ELSE with_check 
    END as with_check_clause
FROM pg_policies 
WHERE tablename = 'sales'
ORDER BY cmd, policyname;

-- ===================================
-- ملاحظات مهمة
-- Important Notes
-- ===================================
/*
1. تأكد من تشغيل هذا السكريبت في Supabase SQL Editor
   Make sure to run this in Supabase SQL Editor

2. السياسات المُنشأة تسمح بالوصول الكامل لجميع المستخدمين
   The created policies allow full access for all users
   
3. إذا كنت تريد تقييد الوصول، يمكنك تعديل شروط USING و WITH CHECK
   If you want to restrict access, modify USING and WITH CHECK conditions

4. بعد تشغيل هذا السكريبت:
   After running this script:
   - أعد تحميل صفحة reports.html
     Reload reports.html page
   - افتح Console المتصفح (F12)
     Open browser Console (F12)
   - جرّب تحديث التاريخ
     Try updating a date
   - راقب الرسائل في Console
     Monitor messages in Console

5. إذا استمرت المشكلة، تحقق من:
   If issue persists, check:
   ✓ اتصال الإنترنت (Internet connection)
   ✓ صلاحيات المستخدم في جدول employees (User permissions in employees table)
   ✓ صحة مفاتيح Supabase (Supabase keys validity)
   ✓ اسم العمود في الجدول (Column name in table - case sensitive!)
*/
