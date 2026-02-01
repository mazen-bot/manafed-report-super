-- تفعيل سياسات RLS للسماح بالقراءة والكتابة للجداول

-- سياسات جدول employees
DROP POLICY IF EXISTS "Allow public read employees" ON employees;
DROP POLICY IF EXISTS "Allow public insert employees" ON employees;
DROP POLICY IF EXISTS "Allow public update employees" ON employees;
DROP POLICY IF EXISTS "Allow public delete employees" ON employees;

CREATE POLICY "Allow public read employees" ON employees FOR SELECT USING (true);
CREATE POLICY "Allow public insert employees" ON employees FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update employees" ON employees FOR UPDATE USING (true);
CREATE POLICY "Allow public delete employees" ON employees FOR DELETE USING (true);

-- سياسات جدول branches
DROP POLICY IF EXISTS "Allow public read branches" ON branches;
DROP POLICY IF EXISTS "Allow public insert branches" ON branches;
DROP POLICY IF EXISTS "Allow public update branches" ON branches;
DROP POLICY IF EXISTS "Allow public delete branches" ON branches;

CREATE POLICY "Allow public read branches" ON branches FOR SELECT USING (true);
CREATE POLICY "Allow public insert branches" ON branches FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update branches" ON branches FOR UPDATE USING (true);
CREATE POLICY "Allow public delete branches" ON branches FOR DELETE USING (true);

-- سياسات جدول sales
DROP POLICY IF EXISTS "Allow public read sales" ON sales;
DROP POLICY IF EXISTS "Allow public insert sales" ON sales;
DROP POLICY IF EXISTS "Allow public update sales" ON sales;
DROP POLICY IF EXISTS "Allow public delete sales" ON sales;

CREATE POLICY "Allow public read sales" ON sales FOR SELECT USING (true);
CREATE POLICY "Allow public insert sales" ON sales FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update sales" ON sales FOR UPDATE USING (true);
CREATE POLICY "Allow public delete sales" ON sales FOR DELETE USING (true);
