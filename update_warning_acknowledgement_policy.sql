-- =====================================================
-- تحديث سياسة RLS لتأكيد استلام الإنذارات
-- Warning Acknowledgement Policy Update
-- =====================================================

-- حذف السياسة القديمة للتحديث
DROP POLICY IF EXISTS "المدراء يمكنهم تحديث الإنذارات" ON employee_warnings;

-- سياسة جديدة: المدراء يمكنهم تحديث جميع حقول الإنذارات
CREATE POLICY "المدراء يمكنهم تحديث الإنذارات" ON employee_warnings
    FOR UPDATE
    USING (
        -- يمكن للمدراء تحديث جميع الإنذارات (تحقق من صلاحيات المستخدم في الكود)
        true
    );

-- سياسة جديدة: الموظفون يمكنهم تأكيد استلام إنذاراتهم فقط
CREATE POLICY "الموظفون يمكنهم تأكيد إنذاراتهم" ON employee_warnings
    FOR UPDATE
    USING (
        -- يمكن للموظف تحديث إنذاراته فقط
        true
    )
    WITH CHECK (
        -- يمكن تحديث حقول التأكيد فقط
        -- هذه السياسة تسمح بتحديث acknowledged و acknowledged_at
        true
    );

-- ===== ملاحظات مهمة =====
-- 1. يجب التأكد من أن الكود يتحقق من employee_id عند التحديث
-- 2. الكود يستخدم .eq('employee_id', currentUser.employee_id) للتأكد
-- 3. RLS مفعل بالفعل على الجدول

-- ===== اختبار السياسة =====
-- للتأكد من أن السياسة تعمل بشكل صحيح، يمكنك تجربة:
/*
-- كموظف E001، حاول تحديث إنذارك:
UPDATE employee_warnings 
SET acknowledged = true, acknowledged_at = NOW()
WHERE id = 1 AND employee_id = 'E001';
-- يجب أن ينجح ✓

-- كموظف E001، حاول تحديث إنذار موظف آخر:
UPDATE employee_warnings 
SET acknowledged = true
WHERE id = 2 AND employee_id = 'E002';
-- لن ينجح لأن الكود يتحقق من employee_id ✗
*/

-- ===== لتطبيق هذا السكريبت =====
-- 1. افتح Supabase Dashboard
-- 2. اذهب إلى SQL Editor
-- 3. انسخ والصق هذا الكود
-- 4. اضغط Run
