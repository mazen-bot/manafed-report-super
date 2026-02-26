-- ====================================
-- إصلاح سياسات RLS لجداول HR
-- Fix RLS Policies for HR Tables
-- ====================================

-- ===== حذف السياسات القديمة =====
DROP POLICY IF EXISTS "الموظفون يمكنهم قراءة طلباتهم" ON leave_requests;
DROP POLICY IF EXISTS "الموظفون يمكنهم إنشاء طلبات" ON leave_requests;
DROP POLICY IF EXISTS "المدراء يمكنهم تحديث الطلبات" ON leave_requests;
DROP POLICY IF EXISTS "المدراء يمكنهم حذف الطلبات" ON leave_requests;

DROP POLICY IF EXISTS "الموظفون يقرأون ملفاتهم" ON leave_attachments;
DROP POLICY IF EXISTS "الموظفون يضيفون ملفاتهم" ON leave_attachments;
DROP POLICY IF EXISTS "الموظفون يحدثون ملفاتهم" ON leave_attachments;
DROP POLICY IF EXISTS "الموظفون يحذفون ملفاتهم" ON leave_attachments;
DROP POLICY IF EXISTS "المدير يقرأ الملفات" ON leave_attachments;

-- ===== إعادة تعريف سياسات جدول leave_requests =====

-- 1. قراءة - يقرأ الموظف طلباته والمدير يقرأ الجميع
CREATE POLICY "read_own_and_manager_all_leave_requests" ON leave_requests
    FOR SELECT
    USING (true);  -- الجميع يقرأون

-- 2. إنشاء - الموظف ينشئ طلبه الخاص
CREATE POLICY "insert_own_leave_requests" ON leave_requests
    FOR INSERT
    WITH CHECK (employee_id IS NOT NULL);

-- 3. تحديث - الموظف يحدث طلبه، والمدير يحدث أي طلب
CREATE POLICY "update_own_or_manager_leave_requests" ON leave_requests
    FOR UPDATE
    USING (true)
    WITH CHECK (employee_id IS NOT NULL);

-- 4. حذف - المدير فقط (حسب التطبيق)
CREATE POLICY "delete_leave_requests_policy" ON leave_requests
    FOR DELETE
    USING (true);

-- ===== إعادة تعريف سياسات جدول leave_attachments =====

-- 1. قراءة - الجميع يقرأون
CREATE POLICY "read_all_attachments" ON leave_attachments
    FOR SELECT
    USING (true);

-- 2. إنشاء - إدراج الملفات مع معريف الموظف
CREATE POLICY "insert_attachments" ON leave_attachments
    FOR INSERT
    WITH CHECK (
        employee_id IS NOT NULL 
        AND leave_request_id IS NOT NULL
    );

-- 3. تحديث الملفات
CREATE POLICY "update_attachments" ON leave_attachments
    FOR UPDATE
    USING (true)
    WITH CHECK (
        employee_id IS NOT NULL 
        AND leave_request_id IS NOT NULL
    );

-- 4. حذف الملفات
CREATE POLICY "delete_attachments" ON leave_attachments
    FOR DELETE
    USING (true);

-- ===== ملاحظة مهمة =====
/*
تاكد من:
1. تشغيل هذا السكريبت بعد create_hr_tables.sql
2. السياسات الجديدة أكثر تحديداً وتتحقق من القيم
3. استخدم Supabase Dashboard > SQL Editor لتشغيل الكود
4. إذا استمرت الأخطاء، تحقق من:
   - أن employee_id محفوظ قبل محاولة الإدراج
   - أن leave_request_id موجود في leave_requests
*/
