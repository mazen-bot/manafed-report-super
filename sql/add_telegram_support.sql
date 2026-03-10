-- ================================================
-- إضافة دعم إشعارات تليجرام
-- Adding Telegram Chat ID Support
-- ================================================

-- 1. إضافة عمود telegram_chat_id للموظفين
ALTER TABLE employees 
ADD COLUMN IF NOT EXISTS telegram_chat_id TEXT;

-- 2. إضافة تعليق توضيحي للعمود
COMMENT ON COLUMN employees.telegram_chat_id 
IS 'Telegram Chat ID for bot notifications - obtained from @userinfobot';

-- 3. إضافة index لتحسين الأداء عند البحث
CREATE INDEX IF NOT EXISTS idx_employees_telegram_chat_id 
ON employees(telegram_chat_id);

-- 4. عرض الجدول بعد التعديل
SELECT 
    employee_id,
    name,
    email,
    manager_id,
    telegram_chat_id,
    branch_name
FROM employees
ORDER BY employee_id;

-- ================================================
-- ملاحظات مهمة:
-- ================================================
-- 
-- 1. telegram_chat_id هو رقم فريد لكل مستخدم تليجرام
--    مثال: 987654321
--
-- 2. للحصول على Chat ID:
--    - افتح تليجرام
--    - ابحث عن: @userinfobot
--    - اضغط Start
--    - سيعطيك Chat ID
--
-- 3. لتحديث Chat ID لموظف محدد:
--    UPDATE employees 
--    SET telegram_chat_id = '987654321' 
--    WHERE employee_id = '1001';
--
-- 4. Chat ID يجب يكون نص (TEXT) وليس رقم (BIGINT)
--    لأن بعض Chat IDs تبدأ بـ صفر أو سالب
--
-- 5. العمود اختياري (NULL) - مافي مشكلة لو موظف ما عنده
--
-- ================================================

-- مثال: تحديث Chat ID لموظف واحد
-- UPDATE employees 
-- SET telegram_chat_id = '987654321' 
-- WHERE employee_id = '1001';

-- مثال: تحديث Chat ID لعدة موظفين
-- UPDATE employees SET telegram_chat_id = '111111111' WHERE employee_id = '1001';
-- UPDATE employees SET telegram_chat_id = '222222222' WHERE employee_id = '1002';
-- UPDATE employees SET telegram_chat_id = '333333333' WHERE employee_id = '1003';

-- مثال: عرض الموظفين اللي ما عندهم Chat ID
-- SELECT employee_id, name, email 
-- FROM employees 
-- WHERE telegram_chat_id IS NULL 
-- ORDER BY employee_id;

-- مثال: عرض الموظفين اللي عندهم Chat ID
-- SELECT employee_id, name, email, telegram_chat_id 
-- FROM employees 
-- WHERE telegram_chat_id IS NOT NULL 
-- ORDER BY employee_id;

-- ================================================
-- ✅ تم بنجاح!
-- الآن يمكنك إضافة Chat IDs للموظفين
-- ================================================
