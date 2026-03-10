-- ====================================
-- إعدادات الإجازات واللوائح
-- Leave Settings and Entitlement Rules
-- ====================================

-- ===== تحديث جدول الموظفين =====
ALTER TABLE employees
ADD COLUMN IF NOT EXISTS employment_type TEXT,
ADD COLUMN IF NOT EXISTS job_grade TEXT,
ADD COLUMN IF NOT EXISTS hire_date DATE,
ADD COLUMN IF NOT EXISTS leave_eligible_override BOOLEAN,
ADD COLUMN IF NOT EXISTS annual_leave_days_override INTEGER,
ADD COLUMN IF NOT EXISTS leave_balance_visible_override BOOLEAN;

-- ===== جدول إعدادات الموارد البشرية =====
CREATE TABLE IF NOT EXISTS hr_settings (
    id BIGSERIAL PRIMARY KEY,
    leave_balance_visible BOOLEAN DEFAULT TRUE,
    min_service_months INTEGER DEFAULT 12,
    medical_upload_deadline_days INTEGER DEFAULT 3,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إدراج الإعدادات الافتراضية إن لم توجد
INSERT INTO hr_settings (id, leave_balance_visible, min_service_months, medical_upload_deadline_days)
VALUES (1, TRUE, 12, 3)
ON CONFLICT (id) DO NOTHING;

-- ===== جدول قواعد الاستحقاق =====
CREATE TABLE IF NOT EXISTS leave_entitlement_rules (
    id BIGSERIAL PRIMARY KEY,
    employment_type TEXT NOT NULL,
    job_grade TEXT NOT NULL,
    annual_days INTEGER NOT NULL DEFAULT 30,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uniq_leave_entitlement_rule
ON leave_entitlement_rules (employment_type, job_grade);

-- ===== ملاحظات =====
/*
1. employment_type أمثلة: full_time, part_time, contract
2. job_grade مثال: كاشير / درجة 2
3. annual_leave_days_override إذا وُضع للموظف يتجاوز القواعد
4. leave_eligible_override إذا وُضع للموظف يتجاوز شرط مدة الخدمة
*/
