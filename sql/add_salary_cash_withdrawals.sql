-- =====================================================
-- إضافة ربط سحوبات الرواتب بالمبيعات اليومية
-- Add Salary Cash Withdrawals to Daily Sales
-- =====================================================

-- ===== إضافة عمود سحب الرواتب لجدول المبيعات =====
ALTER TABLE sales 
ADD COLUMN IF NOT EXISTS salary_withdrawal NUMERIC(12,2) DEFAULT 0;

-- إضافة تعليق على العمود
COMMENT ON COLUMN sales.salary_withdrawal IS 'مبلغ سحب الرواتب من الكاش اليومي';

-- ===== إضافة عمود employee_id لربط السحب بالموظف =====
ALTER TABLE sales
ADD COLUMN IF NOT EXISTS salary_employee_id TEXT;

COMMENT ON COLUMN sales.salary_employee_id IS 'الرقم الوظيفي للموظف الذي تم سحب راتبه من الكاش';

-- ===== تحديث جدول monthly_salary_records =====
-- إضافة حقول لتتبع السحوبات الجزئية من الكاش اليومي
ALTER TABLE monthly_salary_records
ADD COLUMN IF NOT EXISTS total_cash_withdrawn NUMERIC(12,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS remaining_amount NUMERIC(12,2);

COMMENT ON COLUMN monthly_salary_records.total_cash_withdrawn IS 'إجمالي المبلغ المسحوب من الكاش حتى الآن';
COMMENT ON COLUMN monthly_salary_records.remaining_amount IS 'المبلغ المتبقي من الراتب';

-- ===== إنشاء جدول لتسجيل تفاصيل سحوبات الرواتب من الكاش اليومي =====
CREATE TABLE IF NOT EXISTS salary_cash_withdrawals (
    id BIGSERIAL PRIMARY KEY,
    
    -- بيانات الموظف
    employee_id TEXT NOT NULL,
    employee_name TEXT NOT NULL,
    branch_name TEXT NOT NULL,
    
    -- بيانات السحب
    withdrawal_amount NUMERIC(12,2) NOT NULL CHECK (withdrawal_amount > 0),
    withdrawal_date DATE NOT NULL DEFAULT CURRENT_DATE,
    salary_month TEXT NOT NULL,
    salary_year INTEGER NOT NULL,
    
    -- ارتباط بسجل المبيعات اليومية
    sales_id BIGINT REFERENCES sales(id) ON DELETE SET NULL,
    
    -- من قام بالسحب
    withdrawn_by TEXT NOT NULL,
    withdrawn_by_name TEXT NOT NULL,
    
    -- ملاحظات
    notes TEXT,
    
    -- تواريخ النظام
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===== إنشاء الفهارس =====
CREATE INDEX IF NOT EXISTS idx_salary_cash_withdrawals_employee ON salary_cash_withdrawals(employee_id);
CREATE INDEX IF NOT EXISTS idx_salary_cash_withdrawals_date ON salary_cash_withdrawals(withdrawal_date DESC);
CREATE INDEX IF NOT EXISTS idx_salary_cash_withdrawals_month ON salary_cash_withdrawals(salary_month, salary_year);
CREATE INDEX IF NOT EXISTS idx_sales_salary_withdrawal ON sales(salary_withdrawal) WHERE salary_withdrawal > 0;

-- ===== تفعيل Row Level Security =====
ALTER TABLE salary_cash_withdrawals ENABLE ROW LEVEL SECURITY;

-- ===== سياسات الأمان =====
CREATE POLICY "الكل يمكنه قراءة سحوبات الرواتب" ON salary_cash_withdrawals
    FOR SELECT USING (true);

CREATE POLICY "المدراء يمكنهم إضافة سحوبات" ON salary_cash_withdrawals
    FOR INSERT WITH CHECK (true);

CREATE POLICY "المدراء يمكنهم تحديث السحوبات" ON salary_cash_withdrawals
    FOR UPDATE USING (true);

CREATE POLICY "المدراء يمكنهم حذف السحوبات" ON salary_cash_withdrawals
    FOR DELETE USING (true);

-- ===== دالة لحساب إجمالي المبلغ المسحوب من راتب الموظف =====
CREATE OR REPLACE FUNCTION get_employee_total_withdrawn(
    p_employee_id TEXT,
    p_month TEXT,
    p_year INTEGER
)
RETURNS NUMERIC AS $$
DECLARE
    total_amount NUMERIC;
BEGIN
    SELECT COALESCE(SUM(withdrawal_amount), 0)
    INTO total_amount
    FROM salary_cash_withdrawals
    WHERE employee_id = p_employee_id
      AND salary_month = p_month
      AND salary_year = p_year;
    
    RETURN total_amount;
END;
$$ LANGUAGE plpgsql;

-- ===== دالة لحساب المبلغ المتبقي من الراتب =====
CREATE OR REPLACE FUNCTION get_employee_remaining_salary(
    p_employee_id TEXT,
    p_month TEXT,
    p_year INTEGER
)
RETURNS NUMERIC AS $$
DECLARE
    net_salary NUMERIC;
    total_withdrawn NUMERIC;
    remaining NUMERIC;
BEGIN
    -- الحصول على صافي الراتب
    SELECT COALESCE(net_salary, 0)
    INTO net_salary
    FROM monthly_salary_records
    WHERE employee_id = p_employee_id
      AND salary_month = p_month
      AND salary_year = p_year;
    
    -- الحصول على إجمالي المسحوب
    total_withdrawn := get_employee_total_withdrawn(p_employee_id, p_month, p_year);
    
    -- حساب المتبقي
    remaining := net_salary - total_withdrawn;
    
    RETURN remaining;
END;
$$ LANGUAGE plpgsql;

-- ===== Trigger لتحديث إجمالي السحوبات في monthly_salary_records =====
CREATE OR REPLACE FUNCTION update_salary_withdrawals_total()
RETURNS TRIGGER AS $$
BEGIN
    -- تحديث إجمالي المسحوب والمتبقي
    UPDATE monthly_salary_records
    SET 
        total_cash_withdrawn = (
            SELECT COALESCE(SUM(withdrawal_amount), 0)
            FROM salary_cash_withdrawals
            WHERE employee_id = NEW.employee_id
              AND salary_month = NEW.salary_month
              AND salary_year = NEW.salary_year
        ),
        remaining_amount = net_salary - (
            SELECT COALESCE(SUM(withdrawal_amount), 0)
            FROM salary_cash_withdrawals
            WHERE employee_id = NEW.employee_id
              AND salary_month = NEW.salary_month
              AND salary_year = NEW.salary_year
        )
    WHERE employee_id = NEW.employee_id
      AND salary_month = NEW.salary_month
      AND salary_year = NEW.salary_year;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_salary_withdrawals
    AFTER INSERT OR UPDATE OR DELETE ON salary_cash_withdrawals
    FOR EACH ROW
    EXECUTE FUNCTION update_salary_withdrawals_total();

-- ===== View لعرض تقرير سحوبات الرواتب من الكاش =====
CREATE OR REPLACE VIEW v_salary_cash_withdrawals_report AS
SELECT 
    s.employee_id,
    s.employee_name,
    s.branch_name,
    s.salary_month,
    s.salary_year,
    s.withdrawal_date,
    s.withdrawal_amount,
    s.withdrawn_by_name,
    sa.sale_date as sale_date,
    sa.total_sales,
    sa.total_cash,
    s.notes
FROM salary_cash_withdrawals s
LEFT JOIN sales sa ON s.sales_id = sa.id
ORDER BY s.withdrawal_date DESC, s.created_at DESC;

-- ===== View لملخص رواتب الموظفين الشهرية =====
CREATE OR REPLACE VIEW v_employee_monthly_salary_summary AS
SELECT 
    m.employee_id,
    m.employee_name,
    m.branch_name,
    m.salary_month,
    m.salary_year,
    m.net_salary,
    COALESCE(m.total_cash_withdrawn, 0) as total_cash_withdrawn,
    COALESCE(m.remaining_amount, m.net_salary) as remaining_amount,
    m.payment_status,
    COUNT(w.id) as withdrawal_count,
    CASE 
        WHEN COALESCE(m.total_cash_withdrawn, 0) >= m.net_salary THEN 'مكتمل'
        WHEN COALESCE(m.total_cash_withdrawn, 0) > 0 THEN 'جزئي'
        ELSE 'لم يتم السحب'
    END as withdrawal_status
FROM monthly_salary_records m
LEFT JOIN salary_cash_withdrawals w ON 
    w.employee_id = m.employee_id 
    AND w.salary_month = m.salary_month 
    AND w.salary_year = m.salary_year
GROUP BY 
    m.id,
    m.employee_id,
    m.employee_name,
    m.branch_name,
    m.salary_month,
    m.salary_year,
    m.net_salary,
    m.total_cash_withdrawn,
    m.remaining_amount,
    m.payment_status
ORDER BY m.salary_year DESC, m.salary_month DESC, m.employee_name;

-- ===== تعليقات على الجداول =====
COMMENT ON TABLE salary_cash_withdrawals IS 'سجل سحوبات الرواتب من الكاش اليومي';
COMMENT ON VIEW v_salary_cash_withdrawals_report IS 'تقرير شامل لسحوبات الرواتب من الكاش';
COMMENT ON VIEW v_employee_monthly_salary_summary IS 'ملخص الرواتب الشهرية للموظفين';

-- ===== بيانات تجريبية (اختياري) =====
-- إنشاء سجل راتب شهري للاختبار
INSERT INTO monthly_salary_records (
    employee_id, 
    employee_name, 
    branch_name, 
    base_salary, 
    allowances, 
    deductions, 
    net_salary, 
    salary_month, 
    salary_year, 
    payment_status,
    payment_method
) VALUES (
    'E001',
    'محمد أحمد',
    'الرياض',
    5000.00,
    500.00,
    200.00,
    5300.00,
    '2026-03',
    2026,
    'pending',
    'cash'
) ON CONFLICT (employee_id, salary_month, salary_year) DO NOTHING;

-- ===== انتهى =====
-- 
-- 📝 طريقة الاستخدام:
-- 1. افتح Supabase Dashboard
-- 2. اذهب إلى SQL Editor
-- 3. انسخ والصق هذا الكود
-- 4. اضغط Run
-- 
-- 🎯 ما تم إضافته:
-- ✅ عمود salary_withdrawal في جدول sales
-- ✅ جدول salary_cash_withdrawals لتسجيل السحوبات
-- ✅ دوال لحساب المتبقي من الراتب
-- ✅ Trigger لتحديث الإجماليات تلقائياً
-- ✅ Views للتقارير المفصلة
