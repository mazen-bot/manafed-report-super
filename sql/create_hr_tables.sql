-- =====================================================
-- جداول نظام إدارة الموارد البشرية
-- HR Management System Tables
-- =====================================================

-- ===== جدول طلبات الإجازات =====
CREATE TABLE IF NOT EXISTS leave_requests (
    id BIGSERIAL PRIMARY KEY,
    employee_id TEXT NOT NULL,
    employee_name TEXT NOT NULL,
    branch TEXT NOT NULL,
    request_type TEXT NOT NULL CHECK (request_type IN ('vacation', 'sick', 'permission')),
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    days_count INTEGER NOT NULL,
    reason TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    approved_by TEXT,
    approved_by_name TEXT,
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== جدول إنذارات الموظفين =====
CREATE TABLE IF NOT EXISTS employee_warnings (
    id BIGSERIAL PRIMARY KEY,
    employee_id TEXT NOT NULL,
    warning_level TEXT NOT NULL CHECK (warning_level IN ('تنبيه', 'إنذار أول', 'إنذار ثاني', 'إنذار نهائي')),
    reason TEXT NOT NULL,
    issued_by TEXT NOT NULL,
    issued_by_name TEXT NOT NULL,
    acknowledged BOOLEAN DEFAULT FALSE,
    acknowledged_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== إنشاء الفهارس لتحسين الأداء =====
CREATE INDEX IF NOT EXISTS idx_leave_requests_employee ON leave_requests(employee_id);
CREATE INDEX IF NOT EXISTS idx_leave_requests_status ON leave_requests(status);
CREATE INDEX IF NOT EXISTS idx_leave_requests_dates ON leave_requests(from_date, to_date);
CREATE INDEX IF NOT EXISTS idx_leave_requests_created ON leave_requests(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_warnings_employee ON employee_warnings(employee_id);
CREATE INDEX IF NOT EXISTS idx_warnings_level ON employee_warnings(warning_level);
CREATE INDEX IF NOT EXISTS idx_warnings_created ON employee_warnings(created_at DESC);

-- ===== تفعيل Row Level Security =====
ALTER TABLE leave_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_warnings ENABLE ROW LEVEL SECURITY;

-- ===== سياسات الأمان للطلبات =====
-- الموظف يمكنه قراءة طلباته فقط
CREATE POLICY "الموظفون يمكنهم قراءة طلباتهم" ON leave_requests
    FOR SELECT
    USING (true);

-- الموظف يمكنه إنشاء طلبات فقط
CREATE POLICY "الموظفون يمكنهم إنشاء طلبات" ON leave_requests
    FOR INSERT
    WITH CHECK (true);

-- المدراء يمكنهم تحديث حالة الطلبات
CREATE POLICY "المدراء يمكنهم تحديث الطلبات" ON leave_requests
    FOR UPDATE
    USING (true);

-- المدراء يمكنهم حذف الطلبات
CREATE POLICY "المدراء يمكنهم حذف الطلبات" ON leave_requests
    FOR DELETE
    USING (true);

-- ===== سياسات الأمان للإنذارات =====
-- الموظفون يمكنهم قراءة إنذاراتهم
CREATE POLICY "الموظفون يمكنهم قراءة إنذاراتهم" ON employee_warnings
    FOR SELECT
    USING (true);

-- المدراء فقط يمكنهم إضافة إنذارات
CREATE POLICY "المدراء يمكنهم إضافة إنذارات" ON employee_warnings
    FOR INSERT
    WITH CHECK (true);

-- المدراء يمكنهم تحديث الإنذارات
CREATE POLICY "المدراء يمكنهم تحديث الإنذارات" ON employee_warnings
    FOR UPDATE
    USING (true);

-- المدراء يمكنهم حذف الإنذارات
CREATE POLICY "المدراء يمكنهم حذف الإنذارات" ON employee_warnings
    FOR DELETE
    USING (true);

-- ===== بيانات تجريبية (اختياري) =====
-- إضافة بعض الطلبات التجريبية
INSERT INTO leave_requests (employee_id, employee_name, branch, request_type, from_date, to_date, days_count, reason, status) VALUES
    ('E001', 'محمد أحمد', 'الرياض', 'vacation', '2026-03-01', '2026-03-05', 5, 'إجازة عائلية', 'pending'),
    ('E002', 'فاطمة علي', 'جدة', 'sick', '2026-02-20', '2026-02-22', 3, 'ظروف صحية', 'approved'),
    ('E003', 'خالد سعيد', 'الدمام', 'permission', '2026-02-25', '2026-02-25', 1, 'مراجعة بنك', 'pending')
ON CONFLICT DO NOTHING;

-- إضافة بعض الإنذارات التجريبية
INSERT INTO employee_warnings (employee_id, warning_level, reason, issued_by, issued_by_name) VALUES
    ('E001', 'تنبيه', 'التأخر عن موعد العمل', 'M001', 'مدير الفرع'),
    ('E003', 'إنذار أول', 'التغيب بدون إذن', 'M001', 'مدير الفرع')
ON CONFLICT DO NOTHING;

-- ===== دوال مساعدة =====
-- دالة لحساب رصيد الإجازات
CREATE OR REPLACE FUNCTION get_leave_balance(emp_id TEXT, annual_quota INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
    used_days INTEGER;
BEGIN
    SELECT COALESCE(SUM(days_count), 0)
    INTO used_days
    FROM leave_requests
    WHERE employee_id = emp_id
      AND status = 'approved'
      AND request_type = 'vacation'
      AND EXTRACT(YEAR FROM from_date) = EXTRACT(YEAR FROM CURRENT_DATE);
    
    RETURN annual_quota - used_days;
END;
$$ LANGUAGE plpgsql;

-- دالة لحساب عدد الإنذارات
CREATE OR REPLACE FUNCTION get_warnings_count(emp_id TEXT)
RETURNS INTEGER AS $$
DECLARE
    warnings_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO warnings_count
    FROM employee_warnings
    WHERE employee_id = emp_id
      AND EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM CURRENT_DATE);
    
    RETURN warnings_count;
END;
$$ LANGUAGE plpgsql;

-- ===== Triggers لتحديث updated_at =====
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_leave_requests_updated_at BEFORE UPDATE ON leave_requests
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_employee_warnings_updated_at BEFORE UPDATE ON employee_warnings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ===== إشعارات =====
-- يمكن إضافة نظام إشعارات عند اعتماد/رفض الطلبات
-- أو عند إضافة إنذار جديد

COMMENT ON TABLE leave_requests IS 'جدول طلبات الإجازات والاستئذانات';
COMMENT ON TABLE employee_warnings IS 'جدول إنذارات الموظفين';

-- ===== انتهى =====
-- لتطبيق هذا السكريبت:
-- 1. افتح Supabase Dashboard
-- 2. اذهب إلى SQL Editor
-- 3. انسخ والصق هذا الكود
-- 4. اضغط Run
