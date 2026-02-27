-- ================================================
-- استكشاف وإصلاح مشاكل Telegram Chat IDs
-- Troubleshooting Telegram Chat ID Issues
-- ================================================

-- 1. عرض جميع الموظفين بدون Chat ID
-- Display all employees without Chat ID
SELECT 
    employee_id,
    name,
    email,
    manager_id,
    telegram_chat_id,
    CASE WHEN telegram_chat_id IS NULL THEN '❌ مفقود' ELSE '✅ موجود' END as chat_id_status
FROM employees
WHERE telegram_chat_id IS NULL
ORDER BY employee_id;

-- ================================================

-- 2. عرض المديرين اللي ما عندهم Chat ID
-- Display managers without Chat ID
SELECT DISTINCT
    e1.employee_id as manager_id,
    e2.name as manager_name,
    e2.email as manager_email,
    e2.telegram_chat_id,
    COUNT(e1.employee_id) as number_of_employees,
    CASE WHEN e2.telegram_chat_id IS NULL THEN '❌ مفقود' ELSE '✅ موجود' END as chat_id_status
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.employee_id
WHERE e1.manager_id IS NOT NULL
GROUP BY e1.manager_id, e2.name, e2.email, e2.telegram_chat_id
HAVING e2.telegram_chat_id IS NULL
ORDER BY number_of_employees DESC;

-- ================================================

-- 3. عرض ملخص كامل لـ Chat IDs
-- Summary of all Chat ID status
SELECT
    COUNT(*) as total_employees,
    SUM(CASE WHEN telegram_chat_id IS NOT NULL THEN 1 ELSE 0 END) as has_chat_id,
    SUM(CASE WHEN telegram_chat_id IS NULL THEN 1 ELSE 0 END) as missing_chat_id,
    ROUND(
        SUM(CASE WHEN telegram_chat_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / 
        COUNT(*), 2
    ) as percentage_complete
FROM employees;

-- ================================================

-- 4. عرض تفاصيل كل موظف مع حالة Chat ID
-- Detailed view of all employees with Chat ID status
SELECT
    employee_id,
    name,
    branch_name,
    manager_id,
    telegram_chat_id,
    CASE 
        WHEN telegram_chat_id IS NULL THEN '❌ بدون Chat ID'
        ELSE '✅ لديه Chat ID'
    END as status,
    CASE 
        WHEN manager_id IS NULL THEN '⚠️ بدون مدير'
        ELSE 'لديه مدير: ' || manager_id
    END as manager_status
FROM employees
ORDER BY employee_id;

-- ================================================

-- 5. عرض الموظفين بدون مدير
-- Display employees without manager assigned
SELECT
    employee_id,
    name,
    email,
    branch_name,
    telegram_chat_id
FROM employees
WHERE manager_id IS NULL
ORDER BY employee_id;

-- ================================================

-- 6. إضافة Chat ID تجريبي (استخدم هذا للاختبار)
-- Add test Chat ID (use this for testing)
-- (استبدل 1001 برقم الموظف و 123456789 بـ Chat ID الفعلي)
-- (Replace 1001 with employee ID and 123456789 with actual Chat ID)

UPDATE employees 
SET telegram_chat_id = '123456789' 
WHERE employee_id = '1001';

-- ================================================

-- 7. حذف جميع Chat IDs (في حالة الحاجة للإعادة)
-- Delete all Chat IDs (if you need to reset)
-- تحذير: هذا سيحذف جميع Chat IDs - تأكد قبل التنفيذ!
-- WARNING: This will delete ALL Chat IDs - confirm before running!

-- UPDATE employees SET telegram_chat_id = NULL;

-- ================================================

-- 8. عرض جميع Chat IDs الموجودة حالياً
-- Display all existing Chat IDs
SELECT
    employee_id,
    name,
    telegram_chat_id,
    LENGTH(telegram_chat_id) as id_length
FROM employees
WHERE telegram_chat_id IS NOT NULL
ORDER BY employee_id;

-- ================================================

-- 9. إضافة Chat IDs العشوائية (للاختبار فقط)
-- Add random Chat IDs (for testing only)

-- مثال: إضافة Chat ID لموظفين محددين
-- Example: Add Chat ID for specific employees

-- UPDATE employees SET telegram_chat_id = '111111111' WHERE employee_id = '1001';
-- UPDATE employees SET telegram_chat_id = '222222222' WHERE employee_id = '1002';
-- UPDATE employees SET telegram_chat_id = '333333333' WHERE employee_id = '1003';
-- UPDATE employees SET telegram_chat_id = '444444444' WHERE employee_id = '1004';

-- ================================================

-- 10. بحث عن موظف محدد والتحقق من حالته
-- Search for specific employee and check status
-- (غيّر 1001 برقم الموظف اللي تبحث عنه)
-- (Replace 1001 with the employee ID you're looking for)

SELECT
    e.employee_id,
    e.name,
    e.email,
    e.manager_id,
    e.telegram_chat_id,
    m.name as manager_name,
    m.telegram_chat_id as manager_chat_id,
    CASE 
        WHEN e.telegram_chat_id IS NULL THEN '❌ الموظف: بدون Chat ID'
        ELSE '✅ الموظف: لديه Chat ID'
    END as employee_status,
    CASE 
        WHEN m.telegram_chat_id IS NULL THEN '❌ المدير: بدون Chat ID'
        WHEN m.telegram_chat_id IS NOT NULL THEN '✅ المدير: لديه Chat ID'
        ELSE '⚠️ المدير: غير موجود'
    END as manager_status
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
WHERE e.employee_id = '1001';  -- غيّر رقم الموظف هنا

-- ================================================

-- 11. عرض الموظفين والمديرين اللي ما عندهم Chat ID
-- Display employees and their managers without Chat ID
SELECT
    e.employee_id as emp_id,
    e.name as emp_name,
    CASE WHEN e.telegram_chat_id IS NULL THEN '❌' ELSE '✅' END as emp_chat_id_status,
    e.manager_id,
    m.name as manager_name,
    CASE WHEN m.telegram_chat_id IS NULL THEN '❌' ELSE '✅' END as mgr_chat_id_status
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
WHERE e.telegram_chat_id IS NULL OR m.telegram_chat_id IS NULL
ORDER BY e.employee_id;

-- ================================================

-- 12. تحديث مجموعة من الموظفين بـ Chat IDs (نموذج جماعي)
-- Bulk update multiple employees with Chat IDs (bulk template)

BEGIN;  -- ابدأ transaction

-- أضف التحديثات هنا
UPDATE employees SET telegram_chat_id = '111111111' WHERE employee_id = '1001';
UPDATE employees SET telegram_chat_id = '222222222' WHERE employee_id = '1002';
UPDATE employees SET telegram_chat_id = '333333333' WHERE employee_id = '1003';

COMMIT;  -- احفظ التغييرات

-- أو استخدم ROLLBACK إذا حدث خطأ
-- Or use ROLLBACK if error occurs

-- ================================================

-- 13. إصلاح سريع: تعيين مدير افتراضي لمن لا يملك مدير
-- Quick fix: Assign default manager to employees without manager

UPDATE employees 
SET manager_id = '1003'
WHERE manager_id IS NULL;

-- ================================================

-- 14. عرض إحصائيات الإكمال
-- Display completion statistics

SELECT
    (SELECT COUNT(*) FROM employees) as total_employees,
    (SELECT COUNT(*) FROM employees WHERE telegram_chat_id IS NOT NULL) as employees_with_chat_id,
    (SELECT COUNT(*) FROM employees WHERE manager_id IS NOT NULL 
     AND telegram_chat_id IS NOT NULL) as managers_with_chat_id,
    ROUND(
        (SELECT COUNT(*) FROM employees WHERE telegram_chat_id IS NOT NULL)::numeric / 
        (SELECT COUNT(*) FROM employees)::numeric * 100, 2
    ) as percentage_employees_complete,
    ROUND(
        (SELECT COUNT(*) FROM employees WHERE manager_id IS NOT NULL AND telegram_chat_id IS NOT NULL)::numeric / 
        (SELECT COUNT(DISTINCT manager_id) FROM employees WHERE manager_id IS NOT NULL)::numeric * 100, 2
    ) as percentage_managers_complete;

-- ================================================

-- 15. رابط سريع لقائمة المشاكل والحلول
-- Quick reference for troubleshooting

-- المشكلة 1: الموظف بدون Chat ID
-- Problem 1: Employee without Chat ID
-- الحل: افتح admin.html → اضغط "Chat ID" → أدخل Chat ID من @userinfobot

-- المشكلة 2: المدير بدون Chat ID
-- Problem 2: Manager without Chat ID
-- الحل: نفس الخطوات للمدير

-- المشكلة 3: الموظف بدون مدير
-- Problem 3: Employee without manager
-- SQL الحل: UPDATE employees SET manager_id = '1003' WHERE employee_id = 'XXX';

-- ================================================

-- 💡 نصائح مهمة:
-- - استخدم SELECT قبل UPDATE للتأكد من البيانات الصحيحة
-- - تأكد من وجود Chat ID الصحيح قبل الإدراج
-- - احفظ backup من قاعدة البيانات قبل التحديثات الضخمة
-- - اختبر مع موظف واحد أولاً

-- ================================================
