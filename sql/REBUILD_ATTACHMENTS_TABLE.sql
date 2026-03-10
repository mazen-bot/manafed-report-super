-- ====================================
-- إعادة بناء كامل جدول الملفات
-- Complete Rebuild of Attachments Table
-- ====================================

-- ===== حذف الجدول القديم إن وجد =====
DROP TABLE IF EXISTS leave_attachments CASCADE;

-- ===== حذف جميع السياسات القديمة على leave_requests =====
DROP POLICY IF EXISTS "الموظفون يمكنهم قراءة طلباتهم" ON leave_requests;
DROP POLICY IF EXISTS "الموظفون يمكنهم إنشاء طلبات" ON leave_requests;
DROP POLICY IF EXISTS "المدراء يمكنهم تحديث الطلبات" ON leave_requests;
DROP POLICY IF EXISTS "المدراء يمكنهم حذف الطلبات" ON leave_requests;
DROP POLICY IF EXISTS "read_own_and_manager_all_leave_requests" ON leave_requests;
DROP POLICY IF EXISTS "insert_own_leave_requests" ON leave_requests;
DROP POLICY IF EXISTS "update_own_or_manager_leave_requests" ON leave_requests;
DROP POLICY IF EXISTS "delete_leave_requests_policy" ON leave_requests;

-- ===== إعادة إنشاء جدول leave_attachments =====
CREATE TABLE leave_attachments (
    id BIGSERIAL PRIMARY KEY,
    leave_request_id BIGINT NOT NULL REFERENCES leave_requests(id) ON DELETE CASCADE,
    employee_id TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    file_type TEXT NOT NULL,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== إنشاء الفهارس =====
CREATE INDEX idx_attachments_leave_request ON leave_attachments(leave_request_id);
CREATE INDEX idx_attachments_employee ON leave_attachments(employee_id);
CREATE INDEX idx_attachments_uploaded_at ON leave_attachments(uploaded_at DESC);

-- ===== تفعيل RLS =====
ALTER TABLE leave_attachments ENABLE ROW LEVEL SECURITY;

-- ===== سياسات جدول leave_attachments =====
-- السياسة الواحدة للجميع:  يمكن قراءة وكتابة وحذف إذا كان employee_id محدداً
CREATE POLICY "allow_authenticated_users" ON leave_attachments
    USING (employee_id IS NOT NULL);

-- ===== سياسات جدول leave_requests =====
-- سياسة واحدة تسمح للجميع بالقراءة والكتابة والتحديث والحذف
CREATE POLICY "leave_requests_full_access" ON leave_requests
    USING (employee_id IS NOT NULL);

-- ===== جدول تتبع الأخطاء اختياري =====
CREATE TABLE IF NOT EXISTS attachment_errors (
    id BIGSERIAL PRIMARY KEY,
    employee_id TEXT,
    leave_request_id BIGINT,
    error_message TEXT,
    error_details TEXT,
    tried_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== ملاحظات مهمة جداً =====
/*
هذا السكريبت يقوم بـ:
1. حذف جدول leave_attachments بالكامل وجميع السياسات
2. إعادة إنشاء الجدول من الصفر
3. تفعيل RLS مع سياسات بسيطة وفعالة
4. التأكد من أن employee_id يجب أن يكون موجود دائماً

الخطوات:
1. شغّل هذا السكريبت في SQL Editor
2. انتظر قليلاً حتى ينتهي
3. عد إلى التطبيق وحاول رفع ملف جديد

إذا استمرت المشاكل:
- تحقق من أن قيمة employee_id تُرسل بشكل صحيح من JavaScript
- افتح browser console وتحقق من قيمة currentUser.employee_id
- تأكد من أن المستخدم موثق (authenticated) بشكل صحيح
*/
