-- ====================================
-- تعيين المدير الافتراضي لجميع الموظفين
-- Set Default Manager for All Employees
-- ====================================

-- تحديث جميع الموظفين الذين ليس لهم مدير
-- وتعيين 1003 كمدير افتراضي لهم
UPDATE employees
SET manager_id = '1003'
WHERE (manager_id IS NULL OR manager_id = '')
  AND employee_id != '1003'; -- استثناء المدير نفسه

-- التحقق من النتائج
SELECT 
    employee_id,
    name,
    branch_name,
    manager_id,
    email
FROM employees
ORDER BY employee_id;

-- عرض عدد الموظفين الذين تم تحديثهم
SELECT 
    COUNT(*) as total_employees_with_manager
FROM employees
WHERE manager_id = '1003';

-- ====================================
-- ملاحظات:
-- 1. يتم تحديث فقط الموظفين الذين ليس لهم مدير محدد
-- 2. المدير 1003 نفسه لا يتم تحديثه
-- 3. يمكنك تغيير الرقم 1003 إلى أي رقم وظيفي آخر
-- 4. تأكد من أن المدير 1003 موجود في النظام وله بريد إلكتروني
-- ====================================

-- للتحقق من معلومات المدير 1003
SELECT 
    employee_id,
    name,
    email,
    branch_name
FROM employees
WHERE employee_id = '1003';
