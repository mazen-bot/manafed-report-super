# ✅ إصلاح خطأ "Error fetching employee/manager emails"

## المشكلة
كان هناك خطأ في الاستعلام من قاعدة البيانات - كان الكود يبحث عن عمود `id` بينما جدول الموظفين يستخدم `employee_id`.

## الحل المطبق

### 1. تصحيح استعلام قاعدة البيانات ✅

تم تعديل ملف `emailjs-notifications.js` ليستخدم `employee_id` بدلاً من `id`:

```javascript
// ❌ القديم (خطأ)
.select('id, name, email, manager_id')
.eq('id', employeeId)

// ✅ الجديد (صحيح)
.select('employee_id, name, email, manager_id')
.eq('employee_id', employeeId)
```

### 2. إضافة عمود البريد الإلكتروني

تم إنشاء ملف `add_email_column.sql` لإضافة عمود البريد الإلكتروني إلى جدول الموظفين.

---

## خطوات التنفيذ المطلوبة

### الخطوة 1: تشغيل SQL في Supabase

1. افتح Supabase Dashboard
2. اذهب إلى **SQL Editor**
3. افتح ملف `add_email_column.sql` ونسخ محتواه
4. الصق الكود في SQL Editor
5. اضغط **Run**

هذا سيضيف عمود `email` إلى جدول `employees` إذا لم يكن موجوداً.

### الخطوة 2: تحديث البريد الإلكتروني للموظفين

يجب إضافة البريد الإلكتروني لكل موظف:

```sql
-- مثال: تحديث البريد الإلكتروني لموظف واحد
UPDATE employees 
SET email = 'mohammed@company.com' 
WHERE employee_id = 'E001';

-- مثال: تحديث عدة موظفين دفعة واحدة
UPDATE employees SET email = 'ahmad@company.com' WHERE employee_id = 'E001';
UPDATE employees SET email = 'fatima@company.com' WHERE employee_id = 'E002';
UPDATE employees SET email = 'saleh@company.com' WHERE employee_id = 'E003';
```

**⚠️ مهم جداً:**
- يجب أن يكون لكل موظف ومدير بريد إلكتروني صحيح
- إذا لم يكن للموظف بريد إلكتروني، لن يتم إرسال الإشعارات له

### الخطوة 3: التحقق من EmailJS

تأكد من أن EmailJS محمّل بشكل صحيح:

#### الطريقة 1: التحميل المحلي (الأفضل)
1. افتح `setup-emailjs-offline.html` في المتصفح
2. اضغط زر "Download EmailJS Library"
3. سيتم تنزيل ملف `email.min.js` تلقائياً
4. ضع ملف `email.min.js` في نفس مجلد `hr-management.html`

#### الطريقة 2: CDN (البديل)
إذا لم ينجح التحميل المحلي، سيجرب النظام التحميل من CDN تلقائياً.

### الخطوة 4: إنشاء قوالب EmailJS

يجب إنشاء 4 قوالب في EmailJS Dashboard:

1. **template_leave_request** - إشعار طلب إجازة جديد
2. **template_leave_approval** - إشعار الموافقة/الرفض
3. **template_medical_reminder** - تذكير برفع الشهادة الطبية
4. **template_warning_issued** - إشعار إنذار جديد

راجع ملف `EMAILJS_SETUP_GUIDE.md` للتفاصيل الكاملة.

---

## اختبار النظام

### 1. افتح Console في المتصفح

اضغط `F12` في Chrome/Edge

### 2. قم بعملية اختبار

- قدّم طلب إجازة جديد
- أو وافق/ارفض طلب موجود
- أو أصدر إنذار لموظف

### 3. تحقق من الرسائل في Console

#### رسائل النجاح ✅
```
✅ EmailJS loaded from local file
✅ EmailJS initialized successfully
📧 Sending leave request notification...
✅ Leave request email sent successfully
```

#### رسائل الخطأ المحتملة ❌

**خطأ: "EmailJS library did not load"**
- افتح `setup-emailjs-offline.html` وحمّل المكتبة محلياً
- أو تحقق من اتصال الإنترنت

**خطأ: "Error fetching employee/manager emails"**
- تحقق من تشغيل `add_email_column.sql`
- تأكد من وجود بريد إلكتروني للموظف في قاعدة البيانات

**خطأ: "Template not found"**
- أنشئ القوالب في EmailJS Dashboard
- تحقق من صحة اسم القالب

**خطأ: "Email sending failed"**
- تحقق من Service ID و Public Key في `emailjs-notifications.js`
- تأكد من أن EmailJS Service نشط

---

## التحقق من البريد الإلكتروني

### خطوة سريعة للتحقق

شغّل هذا الأمر في Supabase SQL Editor:

```sql
-- عرض جميع الموظفين مع البريد الإلكتروني
SELECT 
    employee_id, 
    name, 
    email, 
    branch_name,
    manager_id
FROM employees
ORDER BY employee_id;
```

تحقق من:
- ❓ هل عمود `email` موجود؟
- ❓ هل كل موظف لديه بريد إلكتروني؟
- ❓ هل المدراء (manager_id) لديهم بريد إلكتروني؟

---

## الملفات المعدّلة

1. ✅ `emailjs-notifications.js` - تم إصلاح استعلام قاعدة البيانات
2. ✅ `add_email_column.sql` - **جديد** - لإضافة عمود البريد الإلكتروني
3. ✅ هذا الدليل - خطوات الإصلاح

---

## الخلاصة

### ما تم إصلاحه:
✅ استعلام قاعدة البيانات يستخدم `employee_id` الآن بدلاً من `id`  
✅ إضافة رسائل خطأ تفصيلية لتسهيل التشخيص  

### ما يجب عليك فعله:
1. ⚠️ تشغيل `add_email_column.sql` في Supabase
2. ⚠️ تحديث البريد الإلكتروني لكل موظف
3. ⚠️ تحميل EmailJS محلياً باستخدام `setup-emailjs-offline.html`
4. ⚠️ إنشاء 4 قوالب EmailJS

### بعد إتمام الخطوات:
✨ سيعمل نظام الإشعارات بالكامل  
📧 سيتم إرسال إشعارات للموظفين والمدراء تلقائياً  
🔔 جميع الأحداث (طلبات، موافقات، تذكيرات، إنذارات) ستُرسل بالبريد  

---

**ملاحظة:** إذا واجهت أي مشاكل، تحقق من رسائل Console في المتصفح (F12).
