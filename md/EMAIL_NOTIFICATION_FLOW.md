# ✅ تحديث: نظام إرسال الإشعارات

## 📧 كيف يعمل النظام الآن

### 1️⃣ عند رفع طلب إجازة
**يتم الإرسال إلى: المدير فقط** ✅

```
موظف يرفع طلب إجازة
     ↓
📧 إشعار للمدير: "موظف X طلب إجازة من... إلى..."
     ↓
المدير يراجع الطلب
```

**ملاحظة مهمة:** يجب أن يكون للموظف `manager_id` محدد في قاعدة البيانات، وإلا لن يُرسل الإشعار.

---

### 2️⃣ عند الموافقة أو الرفض
**يتم الإرسال إلى: الموظف فقط** ✅

```
المدير يوافق/يرفض الطلب
     ↓
📧 إشعار للموظف: "تم الموافقة على طلبك" أو "تم رفض طلبك"
     ↓
الموظف يستلم النتيجة
```

---

## 🔧 المتطلبات

### 1. إضافة الأعمدة المطلوبة

شغّل هذا SQL في Supabase:

```sql
-- إضافة عمود البريد الإلكتروني
ALTER TABLE employees
ADD COLUMN IF NOT EXISTS email TEXT;

-- إضافة عمود المدير المباشر
ALTER TABLE employees
ADD COLUMN IF NOT EXISTS manager_id TEXT;

-- إنشاء فهرس
CREATE INDEX IF NOT EXISTS idx_employees_email ON employees(email);
```

أو استخدم ملف: [add_email_column.sql](add_email_column.sql)

---

### 2. تعبئة البيانات

#### إضافة البريد الإلكتروني لكل موظف:

من [admin.html](admin.html):
1. اذهب لقسم **📧 إدارة الإيميلات**
2. أضف البريد لكل موظف

أو من SQL Editor:
```sql
UPDATE employees 
SET email = 'ahmad@company.com' 
WHERE employee_id = 'E001';
```

#### تحديد المدير المباشر لكل موظف:

```sql
UPDATE employees 
SET manager_id = 'M001'  -- الرقم الوظيفي للمدير
WHERE employee_id = 'E001';
```

مثال - ربط 3 موظفين بمدير واحد:
```sql
UPDATE employees SET manager_id = 'M001' WHERE employee_id = 'E001';
UPDATE employees SET manager_id = 'M001' WHERE employee_id = 'E002';
UPDATE employees SET manager_id = 'M001' WHERE employee_id = 'E003';
```

---

## 📋 سير العمل الكامل

### مثال عملي:

**الموظف:** أحمد (E001) - `ahmad@company.com`  
**المدير:** محمد (M001) - `mohammed@company.com`

#### الخطوة 1: أحمد يرفع طلب إجازة
```
✅ تم رفع الطلب
📧 إشعار يُرسل لـ: mohammed@company.com
📝 المحتوى: "الموظف أحمد طلب إجازة من 2026-03-01 إلى 2026-03-05"
```

**لا يُرسل** إشعار لأحمد في هذه المرحلة ❌

---

#### الخطوة 2: محمد يراجع ويوافق على الطلب
```
✅ تمت الموافقة
📧 إشعار يُرسل لـ: ahmad@company.com
📝 المحتوى: "تم الموافقة على طلب إجازتك من 2026-03-01 إلى 2026-03-05 ✅"
```

**لا يُرسل** إشعار لمحمد في هذه المرحلة ❌

---

## 🎯 قوالب EmailJS المطلوبة

يجب إنشاء قالبين في EmailJS Dashboard:

### 1. قالب طلب الإجازة (للمدير)
**اسم القالب:** `template_leave_request`

```
الموضوع: طلب إجازة جديد من {{employee_name}}

عزيزي المدير،

تم رفع طلب إجازة جديد:

الموظف: {{employee_name}}
نوع الإجازة: {{leave_type}}
من تاريخ: {{from_date}}
إلى تاريخ: {{to_date}}
عدد الأيام: {{days_count}}
السبب: {{reason}}

يرجى مراجعة الطلب من نظام إدارة الموارد البشرية.

تاريخ الطلب: {{request_date}}
```

### 2. قالب الموافقة/الرفض (للموظف)
**اسم القالب:** `template_leave_approval`

```
الموضوع: حالة طلب الإجازة: {{approval_status}}

عزيزي {{employee_name}}،

طلب إجازتك:
النوع: {{leave_type}}
من: {{from_date}}
إلى: {{to_date}}

الحالة: {{approval_status}}

ملاحظات: {{approver_notes}}

تاريخ الرد: {{approval_date}}
```

---

## ✅ التحقق من النظام

### اختبار 1: طلب جديد

1. سجّل دخول كموظف في [hr-management.html](hr-management.html)
2. قدّم طلب إجازة جديد
3. **تحقق:** هل وصل إشعار لإيميل المدير؟ ✅
4. **تحقق:** هل **لم يصل** إشعار لإيميل الموظف؟ ✅

### اختبار 2: موافقة/رفض

1. سجّل دخول كمدير
2. وافق أو ارفض الطلب
3. **تحقق:** هل وصل إشعار لإيميل الموظف؟ ✅
4. **تحقق:** هل **لم يصل** إشعار لإيميل المدير؟ ✅

---

## 🔍 رسائل Console

عند رفع طلب:
```
✅ Leave request notification sent to manager
```

عند الموافقة/الرفض:
```
✅ Leave approved notification sent to employee
```

---

## ⚠️ حل المشاكل

### المشكلة: لم يصل الإشعار للمدير عند رفع الطلب

**الأسباب المحتملة:**

1. **الموظف ليس له manager_id:**
```sql
-- تحقق من manager_id
SELECT employee_id, name, manager_id 
FROM employees 
WHERE employee_id = 'E001';

-- إذا كان NULL، حدّده
UPDATE employees 
SET manager_id = 'M001' 
WHERE employee_id = 'E001';
```

2. **المدير ليس له بريد إلكتروني:**
```sql
-- تحقق من email للمدير
SELECT employee_id, name, email 
FROM employees 
WHERE employee_id = 'M001';

-- إذا كان NULL، أضفه
UPDATE employees 
SET email = 'manager@company.com' 
WHERE employee_id = 'M001';
```

3. **رسالة في Console:**
```
⚠️ No manager email found - notification cannot be sent
```
**الحل:** أضف manager_id للموظف و email للمدير

---

### المشكلة: لم يصل الإشعار للموظف عند الموافقة/الرفض

**السبب:** الموظف ليس له بريد إلكتروني

```sql
-- تحقق من email
SELECT employee_id, name, email 
FROM employees 
WHERE employee_id = 'E001';

-- أضف البريد
UPDATE employees 
SET email = 'employee@company.com' 
WHERE employee_id = 'E001';
```

---

## 📊 الهيكل التنظيمي المثالي

```
المدير العام (M001) - ceo@company.com
  ├── مدير فرع الرياض (M002) - riyadh@company.com
  │     ├── موظف 1 (E001) - emp1@company.com → manager_id = M002
  │     ├── موظف 2 (E002) - emp2@company.com → manager_id = M002
  │     └── موظف 3 (E003) - emp3@company.com → manager_id = M002
  │
  └── مدير فرع جدة (M003) - jeddah@company.com
        ├── موظف 4 (E004) - emp4@company.com → manager_id = M003
        └── موظف 5 (E005) - emp5@company.com → manager_id = M003
```

---

## 📁 الملفات المعدّلة

- ✅ [emailjs-notifications.js](emailjs-notifications.js) - تم تعديل منطق الإرسال
- ✅ [add_email_column.sql](add_email_column.sql) - أضيف عمود manager_id
- ✅ هذا الدليل - توثيق التحديث

---

**💡 ملخص:** الإشعارات الآن أكثر ذكاءً - المدير يُعلم بالطلبات الجديدة، والموظف يُعلم بالنتيجة!
