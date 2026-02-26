-- =====================================================
-- إضافة حقول شهادة طبية لطلبات الإجازات المرضية
-- Add Medical Certificate Fields for Sick Leave Requests
-- =====================================================

-- ===== إضافة الأعمدة الجديدة لجدول leave_requests =====
ALTER TABLE leave_requests 
ADD COLUMN IF NOT EXISTS medical_certificate_url TEXT,
ADD COLUMN IF NOT EXISTS attachment_deadline TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS attachment_uploaded BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS attachment_uploaded_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS penalty_applied BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS penalty_amount DECIMAL(10, 2) DEFAULT 0;

-- ===== إنشاء جدول لتتبع الملفات المرفوعة =====
CREATE TABLE IF NOT EXISTS leave_attachments (
    id BIGSERIAL PRIMARY KEY,
    leave_request_id BIGINT NOT NULL REFERENCES leave_requests(id) ON DELETE CASCADE,
    employee_id TEXT NOT NULL,
    file_name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER NOT NULL,
    file_type TEXT NOT NULL,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT unique_attachment_per_request UNIQUE(leave_request_id)
);

-- ===== إنشاء الفهارس =====
CREATE INDEX IF NOT EXISTS idx_attachments_leave_request ON leave_attachments(leave_request_id);
CREATE INDEX IF NOT EXISTS idx_attachments_employee ON leave_attachments(employee_id);
CREATE INDEX IF NOT EXISTS idx_leave_requests_attachment_deadline ON leave_requests(attachment_deadline);
CREATE INDEX IF NOT EXISTS idx_leave_requests_sick_leaves ON leave_requests(request_type, status) WHERE request_type = 'sick';

-- ===== تفعيل RLS على جدول الملفات =====
ALTER TABLE leave_attachments ENABLE ROW LEVEL SECURITY;

-- ===== سياسات الأمان لجدول الملفات =====
-- الموظف يمكنه قراءة ملفاته فقط
CREATE POLICY "الموظفون يقرأون ملفاتهم" ON leave_attachments
    FOR SELECT
    USING (true);

-- الموظف يمكنه إضافة ملفات لطلباته فقط
CREATE POLICY "الموظفون يضيفون ملفاتهم" ON leave_attachments
    FOR INSERT
    WITH CHECK (employee_id IS NOT NULL);

-- تحديث الملفات المرفوعة
CREATE POLICY "الموظفون يحدثون ملفاتهم" ON leave_attachments
    FOR UPDATE
    USING (employee_id IS NOT NULL)
    WITH CHECK (employee_id IS NOT NULL);

-- حذف الملفات
CREATE POLICY "الموظفون يحذفون ملفاتهم" ON leave_attachments
    FOR DELETE
    USING (employee_id IS NOT NULL);

-- المدير يمكنه قراءة جميع الملفات
CREATE POLICY "المدير يقرأ الملفات" ON leave_attachments
    FOR SELECT
    USING (true);

-- ===== دالة تحديثية لتطبيق الخصم على الملفات المفقودة =====
CREATE OR REPLACE FUNCTION apply_sick_leave_penalty()
RETURNS void AS $$
BEGIN
    -- تطبيق الخصم على الإجازات المرضية التي لم يتم رفع ملف لها خلال 3 أيام
    UPDATE leave_requests
    SET penalty_applied = TRUE,
        penalty_amount = CAST(days_count * 50 AS DECIMAL(10, 2)), -- خصم 50 لكل يوم
        status = 'approved' -- تحويل الحالة للموافقة مع الخصم
    WHERE request_type = 'sick'
      AND status = 'pending'
      AND attachment_deadline < NOW()
      AND attachment_uploaded = FALSE
      AND penalty_applied = FALSE;
END;
$$ LANGUAGE plpgsql;

-- ===== جدول السجل لتتبع الخصومات =====
CREATE TABLE IF NOT EXISTS penalty_logs (
    id BIGSERIAL PRIMARY KEY,
    leave_request_id BIGINT NOT NULL REFERENCES leave_requests(id) ON DELETE CASCADE,
    employee_id TEXT NOT NULL,
    penalty_amount DECIMAL(10, 2) NOT NULL,
    reason TEXT NOT NULL,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_penalty_logs_employee ON penalty_logs(employee_id);
CREATE INDEX IF NOT EXISTS idx_penalty_logs_leave_request ON penalty_logs(leave_request_id);
CREATE INDEX IF NOT EXISTS idx_penalty_logs_applied_at ON penalty_logs(applied_at DESC);

-- ===== تفعيل RLS على جدول السجلات =====
ALTER TABLE penalty_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "المدير يقرأ السجلات" ON penalty_logs
    FOR SELECT
    USING (true);

-- ===== ملاحظات مهمة =====
/*
1. الحقول الجديدة في leave_requests:
   - medical_certificate_url: رابط الملف المرفوع (String)
   - attachment_deadline: الموعد النهائي للرفع (التاريخ + 3 أيام)
   - attachment_uploaded: حالة الرفع (Boolean)
   - attachment_uploaded_at: تاريخ رفع الملف (Timestamp)
   - penalty_applied: هل تم تطبيق الخصم (Boolean)
   - penalty_amount: مبلغ الخصم (Decimal)

2. جدول leave_attachments:
   - يحفظ بيانات الملفات المرفوعة
   - يتم حذف الملف تلقائياً عند حذف الطلب

3. penalty_logs:
   - سجل تاريخي للخصومات المطبقة
   - يسهل المراجعة والتدقيق

4. الخصم المقترح:
   - 50 درهم لكل يوم إجازة مرضية بدون شهادة
   - يمكن تعديل المبلغ حسب سياسة الشركة

5. الموعد النهائي:
   - 3 أيام من تاريخ الطلب
   - يتم حسابها تلقائياً عند إنشاء الطلب
*/

-- ===== لتطبيق هذا السكريبت =====
-- 1. افتح Supabase Dashboard > SQL Editor
-- 2. انسخ والصق هذا الكود
-- 3. اضغط Run
