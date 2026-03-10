-- ====================================
-- إضافة عمود البريد الإلكتروني لجدول الموظفين
-- Add Email Column to Employees Table
-- ====================================

-- إضافة عمود email إذا لم يكن موجوداً
ALTER TABLE employees
ADD COLUMN IF NOT EXISTS email TEXT;

-- إضافة عمود manager_id إذا لم يكن موجوداً
ALTER TABLE employees
ADD COLUMN IF NOT EXISTS manager_id TEXT;

-- إنشاء فهرس للبريد الإلكتروني لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_employees_email ON employees(email);

-- التحقق من إضافة العمود
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'employees' 
AND column_name IN ('email', 'manager_id');

-- ====================================
-- ملاحظات هامة:
-- 1. يجب تحديث البريد الإلكتروني لكل موظف بعد إضافة العمود
-- 2. البريد الإلكتروني ضروري لإرسال الإشعارات عبر EmailJS
-- 3. يمكنك تحديث البريد الإلكتروني للموظفين بهذا الأمر:
--
--    UPDATE employees 
--    SET email = 'employee@company.com' 
--    WHERE employee_id = 'E001';
--
-- 4. يمكنك تحديث المدير المباشر للموظف بهذا الأمر:
--    UPDATE employees
--    SET manager_id = 'M001'
--    WHERE employee_id = 'E001';
-- ====================================
