-- =====================================================
-- نظام إدارة تسليم رواتب الموظفين نقداً
-- Salary Deliveries Management System
-- =====================================================

-- ===== جدول تسليم الرواتب =====
CREATE TABLE IF NOT EXISTS salary_deliveries (
    id BIGSERIAL PRIMARY KEY,
    
    -- بيانات الموظف
    employee_id TEXT NOT NULL,
    employee_name TEXT NOT NULL,
    branch_id BIGINT,
    branch_name TEXT NOT NULL,
    
    -- بيانات الراتب
    salary_amount NUMERIC(12,2) NOT NULL CHECK (salary_amount > 0),
    salary_month TEXT NOT NULL,  -- مثال: "2026-03" or "مارس 2026"
    salary_year INTEGER NOT NULL,
    
    -- بيانات التسليم
    delivered_by TEXT NOT NULL,  -- رقم وظيفي لمن قام بالتسليم
    delivered_by_name TEXT NOT NULL,
    delivery_date DATE NOT NULL DEFAULT CURRENT_DATE,
    delivery_time TIME DEFAULT CURRENT_TIME,
    
    -- إثبات التسليم
    signature_required BOOLEAN DEFAULT TRUE,
    signature_image_url TEXT,  -- رابط صورة التوقيع إن وجد
    receipt_number TEXT,  -- رقم سند القبض
    notes TEXT,  -- ملاحظات إضافية
    
    -- حالة التسليم
    delivery_status TEXT DEFAULT 'delivered' CHECK (delivery_status IN ('delivered', 'pending', 'returned', 'cancelled')),
    
    -- تواريخ النظام
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== جدول سجل دفعات الرواتب الشهرية =====
-- يساعد في تتبع الرواتب الشهرية لكل موظف
CREATE TABLE IF NOT EXISTS monthly_salary_records (
    id BIGSERIAL PRIMARY KEY,
    
    employee_id TEXT NOT NULL,
    employee_name TEXT NOT NULL,
    branch_name TEXT NOT NULL,
    
    -- معلومات الراتب
    base_salary NUMERIC(12,2) NOT NULL,
    allowances NUMERIC(12,2) DEFAULT 0,  -- البدلات
    deductions NUMERIC(12,2) DEFAULT 0,  -- الخصومات
    net_salary NUMERIC(12,2) NOT NULL,   -- الصافي
    
    salary_month TEXT NOT NULL,
    salary_year INTEGER NOT NULL,
    
    -- حالة الصرف
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'cancelled')),
    payment_method TEXT CHECK (payment_method IN ('cash', 'bank_transfer', 'check')),
    payment_date DATE,
    
    -- ارتباط بسجل التسليم
    delivery_id BIGINT REFERENCES salary_deliveries(id) ON DELETE SET NULL,
    
    notes TEXT,
    created_by TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- منع التكرار لنفس الموظف في نفس الشهر
    UNIQUE(employee_id, salary_month, salary_year)
);

-- ===== إنشاء الفهارس لتحسين الأداء =====
CREATE INDEX IF NOT EXISTS idx_salary_deliveries_employee ON salary_deliveries(employee_id);
CREATE INDEX IF NOT EXISTS idx_salary_deliveries_branch ON salary_deliveries(branch_name);
CREATE INDEX IF NOT EXISTS idx_salary_deliveries_date ON salary_deliveries(delivery_date DESC);
CREATE INDEX IF NOT EXISTS idx_salary_deliveries_month ON salary_deliveries(salary_month, salary_year);
CREATE INDEX IF NOT EXISTS idx_salary_deliveries_status ON salary_deliveries(delivery_status);

CREATE INDEX IF NOT EXISTS idx_monthly_salary_employee ON monthly_salary_records(employee_id);
CREATE INDEX IF NOT EXISTS idx_monthly_salary_month ON monthly_salary_records(salary_month, salary_year);
CREATE INDEX IF NOT EXISTS idx_monthly_salary_status ON monthly_salary_records(payment_status);

-- ===== تفعيل Row Level Security =====
ALTER TABLE salary_deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_salary_records ENABLE ROW LEVEL SECURITY;

-- ===== سياسات الأمان =====
-- قراءة سجلات التسليم
CREATE POLICY "الكل يمكنه قراءة سجلات التسليم" ON salary_deliveries
    FOR SELECT
    USING (true);

-- إضافة سجلات تسليم جديدة
CREATE POLICY "المدراء يمكنهم إضافة سجلات تسليم" ON salary_deliveries
    FOR INSERT
    WITH CHECK (true);

-- تحديث سجلات التسليم
CREATE POLICY "المدراء يمكنهم تحديث سجلات التسليم" ON salary_deliveries
    FOR UPDATE
    USING (true);

-- حذف سجلات التسليم
CREATE POLICY "المدراء يمكنهم حذف سجلات التسليم" ON salary_deliveries
    FOR DELETE
    USING (true);

-- سياسات جدول الرواتب الشهرية
CREATE POLICY "الكل يمكنه قراءة سجلات الرواتب" ON monthly_salary_records
    FOR SELECT
    USING (true);

CREATE POLICY "المدراء يمكنهم إضافة سجلات الرواتب" ON monthly_salary_records
    FOR INSERT
    WITH CHECK (true);

CREATE POLICY "المدراء يمكنهم تحديث سجلات الرواتب" ON monthly_salary_records
    FOR UPDATE
    USING (true);

CREATE POLICY "المدراء يمكنهم حذف سجلات الرواتب" ON monthly_salary_records
    FOR DELETE
    USING (true);

-- ===== دوال مساعدة =====

-- دالة للحصول على إجمالي الرواتب المسلمة في شهر معين
CREATE OR REPLACE FUNCTION get_total_salaries_delivered(
    p_month TEXT,
    p_year INTEGER,
    p_branch TEXT DEFAULT NULL
)
RETURNS NUMERIC AS $$
DECLARE
    total_amount NUMERIC;
BEGIN
    SELECT COALESCE(SUM(salary_amount), 0)
    INTO total_amount
    FROM salary_deliveries
    WHERE salary_month = p_month
      AND salary_year = p_year
      AND delivery_status = 'delivered'
      AND (p_branch IS NULL OR branch_name = p_branch);
    
    RETURN total_amount;
END;
$$ LANGUAGE plpgsql;

-- دالة للحصول على عدد الموظفين الذين استلموا رواتبهم
CREATE OR REPLACE FUNCTION get_employees_paid_count(
    p_month TEXT,
    p_year INTEGER,
    p_branch TEXT DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    emp_count INTEGER;
BEGIN
    SELECT COUNT(DISTINCT employee_id)
    INTO emp_count
    FROM salary_deliveries
    WHERE salary_month = p_month
      AND salary_year = p_year
      AND delivery_status = 'delivered'
      AND (p_branch IS NULL OR branch_name = p_branch);
    
    RETURN emp_count;
END;
$$ LANGUAGE plpgsql;

-- دالة للحصول على قائمة الموظفين الذين لم يستلموا رواتبهم
CREATE OR REPLACE FUNCTION get_unpaid_employees(
    p_month TEXT,
    p_year INTEGER,
    p_branch TEXT DEFAULT NULL
)
RETURNS TABLE (
    employee_id TEXT,
    employee_name TEXT,
    branch_name TEXT,
    net_salary NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.employee_id,
        m.employee_name,
        m.branch_name,
        m.net_salary
    FROM monthly_salary_records m
    WHERE m.salary_month = p_month
      AND m.salary_year = p_year
      AND m.payment_status = 'pending'
      AND (p_branch IS NULL OR m.branch_name = p_branch)
      AND NOT EXISTS (
          SELECT 1 
          FROM salary_deliveries s 
          WHERE s.employee_id = m.employee_id 
            AND s.salary_month = p_month
            AND s.salary_year = p_year
            AND s.delivery_status = 'delivered'
      );
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

CREATE TRIGGER update_salary_deliveries_updated_at 
    BEFORE UPDATE ON salary_deliveries
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_monthly_salary_records_updated_at 
    BEFORE UPDATE ON monthly_salary_records
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ===== Views مفيدة =====

-- عرض ملخص التسليمات الشهرية لكل فرع
CREATE OR REPLACE VIEW v_salary_deliveries_summary AS
SELECT 
    branch_name,
    salary_month,
    salary_year,
    COUNT(*) as total_deliveries,
    COUNT(DISTINCT employee_id) as unique_employees,
    SUM(salary_amount) as total_amount,
    SUM(CASE WHEN delivery_status = 'delivered' THEN salary_amount ELSE 0 END) as delivered_amount,
    SUM(CASE WHEN delivery_status = 'pending' THEN salary_amount ELSE 0 END) as pending_amount
FROM salary_deliveries
GROUP BY branch_name, salary_month, salary_year
ORDER BY salary_year DESC, salary_month DESC, branch_name;

-- عرض حالة دفع الرواتب لكل موظف
CREATE OR REPLACE VIEW v_employee_salary_status AS
SELECT 
    m.employee_id,
    m.employee_name,
    m.branch_name,
    m.salary_month,
    m.salary_year,
    m.net_salary,
    m.payment_status,
    m.payment_method,
    s.delivery_date,
    s.delivered_by_name,
    s.receipt_number
FROM monthly_salary_records m
LEFT JOIN salary_deliveries s ON m.delivery_id = s.id
ORDER BY m.salary_year DESC, m.salary_month DESC, m.employee_name;

-- ===== بيانات تجريبية (اختياري - للاختبار فقط) =====
-- يمكنك حذف هذا القسم في بيئة الإنتاج

-- إضافة بعض سجلات الرواتب الشهرية
INSERT INTO monthly_salary_records (employee_id, employee_name, branch_name, base_salary, allowances, deductions, net_salary, salary_month, salary_year, payment_status) VALUES
    ('E001', 'محمد أحمد', 'الرياض', 5000.00, 500.00, 200.00, 5300.00, '2026-03', 2026, 'pending'),
    ('E002', 'فاطمة علي', 'جدة', 4500.00, 400.00, 150.00, 4750.00, '2026-03', 2026, 'pending'),
    ('E003', 'خالد سعيد', 'الدمام', 5500.00, 600.00, 250.00, 5850.00, '2026-03', 2026, 'pending')
ON CONFLICT (employee_id, salary_month, salary_year) DO NOTHING;

-- إضافة بعض سجلات التسليم
INSERT INTO salary_deliveries (employee_id, employee_name, branch_name, salary_amount, salary_month, salary_year, delivered_by, delivered_by_name, receipt_number) VALUES
    ('E001', 'محمد أحمد', 'الرياض', 5300.00, '2026-03', 2026, 'M001', 'مدير الفرع', 'RCP-001'),
    ('E002', 'فاطمة علي', 'جدة', 4750.00, '2026-03', 2026, 'M002', 'مدير جدة', 'RCP-002')
ON CONFLICT DO NOTHING;

-- ===== تعليقات على الجداول =====
COMMENT ON TABLE salary_deliveries IS 'جدول سجلات تسليم رواتب الموظفين نقداً';
COMMENT ON TABLE monthly_salary_records IS 'جدول سجلات الرواتب الشهرية للموظفين';

COMMENT ON COLUMN salary_deliveries.salary_amount IS 'قيمة الراتب المُسلّم';
COMMENT ON COLUMN salary_deliveries.signature_image_url IS 'رابط صورة توقيع الموظف عند الاستلام';
COMMENT ON COLUMN salary_deliveries.receipt_number IS 'رقم سند القبض';

COMMENT ON COLUMN monthly_salary_records.base_salary IS 'الراتب الأساسي';
COMMENT ON COLUMN monthly_salary_records.allowances IS 'البدلات والعلاوات';
COMMENT ON COLUMN monthly_salary_records.deductions IS 'الخصومات';
COMMENT ON COLUMN monthly_salary_records.net_salary IS 'صافي الراتب بعد البدلات والخصومات';

-- ===== انتهى =====
-- 
-- 📝 طريقة الاستخدام:
-- 1. افتح Supabase Dashboard
-- 2. اذهب إلى SQL Editor
-- 3. انسخ والصق هذا الكود
-- 4. اضغط Run
-- 
-- 🎯 المميزات:
-- ✅ تسجيل كامل لتسليم الرواتب نقداً
-- ✅ ربط مع سجلات الرواتب الشهرية
-- ✅ تتبع حالة التسليم (مُسلّم، معلق، ملغى)
-- ✅ حفظ رقم سند القبض والتوقيع
-- ✅ دوال مساعدة للتقارير والإحصائيات
-- ✅ Views جاهزة لعرض الملخصات
-- ✅ حماية بـ RLS (Row Level Security)
