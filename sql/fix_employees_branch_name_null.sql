-- إصلاح branch_name للموظفين القدامى (مرة واحدة)
-- شغّل هذا الملف داخل Supabase SQL Editor

-- 1) معاينة عدد السجلات المتأثرة قبل التحديث
SELECT COUNT(*) AS affected_before
FROM employees e
JOIN branches b ON b.id = e.branch_id
WHERE e.branch_name IS NULL
   OR TRIM(e.branch_name) = ''
   OR LOWER(e.branch_name) = 'null';

-- 2) تحديث branch_name من جدول الفروع
UPDATE employees e
SET branch_name = b.name
FROM branches b
WHERE b.id = e.branch_id
  AND (
    e.branch_name IS NULL
    OR TRIM(e.branch_name) = ''
    OR LOWER(e.branch_name) = 'null'
  );

-- 3) التحقق بعد التحديث
SELECT e.id, e.employee_id, e.name, e.branch_id, e.branch_name
FROM employees e
WHERE e.branch_name IS NULL
   OR TRIM(e.branch_name) = ''
   OR LOWER(e.branch_name) = 'null'
ORDER BY e.id;
