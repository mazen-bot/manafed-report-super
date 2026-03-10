# EmailJS Notifications Setup Guide

## نظرة عامة
تم إضافة نظام الإشعارات البريدية باستخدام EmailJS لتنبيه الموظفين والمديرين بشأن:
- ✅ تقديم طلبات الإجازة
- ✉️ موافقة/رفض الإجازات
- ⏰ تنبيهات انتهاء موعد رفع الشهادات الطبية
- ⚠️ إصدار الإنذارات

---

## الخطوة 1: إنشاء حساب EmailJS

1. اذهب إلى [EmailJS.com](https://www.emailjs.com/)
2. انقر على **Sign Up** وأنشئ حسابًا جديدًا
3. تحقق من بريدك الإلكتروني لتفعيل الحساب

---

## الخطوة 2: الحصول على بيانات الاعتماد

### الحصول على Public Key:
1. اذهب إلى **Account** في لوحة التحكم
2. انسخ **Public Key** من قسم API Keys
3. احفظه - ستحتاجه قريبًا

### الحصول على Service ID:
1. اذهب إلى **Email Services**
2. انقر على **Add Service**
3. اختر أحد الخيارات:
   - **Gmail** (موصى به)
   - **Outlook/Hotmail**
   - **Yahoo**
   - **Custom SMTP**

### مثال: إعداد Gmail Service
   - اختر **Gmail** من قائمة الخدمات
   - انقر **Connect Account**
   - اتبع التعليمات للتصريح لـ EmailJS بالوصول إلى Gmail الخاص بك
   - احفظ **Service ID** (سيظهر بعد الإعداد)

---

## الخطوة 3: إنشاء Email Templates

العودة إلى لوحة التحكم وإنشاء 4 نماذج بريدية:

### Template 1: طلب الإجازة (Leave Request)
**Template ID:** `template_leave_request`

**Main Content:**
```html
<h2>📋 تنبيه: طلب إجازة جديد</h2>

<p>السلام عليكم {{to_name}},</p>

<p>تم تقديم طلب إجازة جديد بالتفاصيل التالية:</p>

<ul style="background: #f0f0f0; padding: 15px; border-radius: 5px;">
    <li><strong>نوع الإجازة:</strong> {{leave_type}}</li>
    <li><strong>من:</strong> {{from_date}}</li>
    <li><strong>إلى:</strong> {{to_date}}</li>
    <li><strong>عدد الأيام:</strong> {{days_count}} يوم</li>
    <li><strong>السبب:</strong> {{reason}}</li>
    <li><strong>تاريخ التقديم:</strong> {{request_date}}</li>
</ul>

<p>سيتم مراجعة الطلب من قبل الإدارة قريبًا.</p>

<p>مع تحيات،<br>نظام إدارة الموارد البشرية</p>
```

**Email Recipient:** {{to_email}}
**Email Subject:** "تنبيه: طلب {{leave_type}} جديد"

---

### Template 2: موافقة/رفض الإجازة (Leave Approval)
**Template ID:** `template_leave_approval`

**Main Content:**
```html
<h2>{{approval_status}} تحديث حالة طلب الإجازة</h2>

<p>السلام عليكم {{to_name}},</p>

<p>تم الرد على طلب إجازتك:</p>

<div style="background: #f0f0f0; padding: 15px; border-radius: 5px;">
    <p><strong>الحالة:</strong> 
        <span style="color: {{status_color}}; font-weight: bold;">{{approval_status}}</span>
    </p>
    <p><strong>من:</strong> {{from_date}}</p>
    <p><strong>إلى:</strong> {{to_date}}</p>
    <p><strong>نوع الإجازة:</strong> {{leave_type}}</p>
    <p><strong>ملاحظات:</strong> {{approver_notes}}</p>
    <p><strong>تاريخ الموافقة:</strong> {{approval_date}}</p>
</div>

<p>شكرًا لك!</p>
```

**Email Recipient:** {{to_email}}
**Email Subject:** "{{approval_status}} - طلب إجازتك"

---

### Template 3: تنبيه انتهاء موعد الشهادة الطبية (Medical Deadline)
**Template ID:** `template_medical_reminder`

**Main Content:**
```html
<h2>⏰ {{urgency_message}}</h2>

<p>السلام عليكم {{to_name}},</p>

<p>هذا تنبيه لك بشأن موعد نهائي قريب لرفع الشهادة الطبية:</p>

<div style="background: #fff3cd; padding: 15px; border-radius: 5px; color: #856404;">
    <p><strong>الإجازة المرضية:</strong></p>
    <ul>
        <li>من: {{from_date}}</li>
        <li>إلى: {{to_date}}</li>
        <li>الأيام المتبقية: {{days_left}}</li>
        <li>الموعد النهائي: {{deadline_date}}</li>
    </ul>
</div>

<p style="color: red;"><strong>⚠️ هام:</strong> يجب رفع الشهادة الطبية قبل انتهاء الموعد لتجنب تطبيق خصم.</p>

<p>الرجاء تسجيل الدخول إلى النظام ورفع الملف فورًا.</p>

```

**Email Recipient:** {{to_email}}
**Email Subject:** "⏰ تنبيه: {{urgency_message}}"

---

### Template 4: إصدار إنذار (Warning Notice)
**Template ID:** `template_warning_issued`

**Main Content:**
```html
<h2>⚠️ تنبيه: تم إصدار إنذار</h2>

<p>السلام عليكم {{to_name}},</p>

<p>تم إصدار إنذار رسمي لك:</p>

<div style="background: #fee; padding: 15px; border-radius: 5px; color: #c33;">
    <p><strong>نوع الإنذار:</strong> {{warning_type}}</p>
    <p><strong>رقم الإنذار:</strong> {{warning_number}}</p>
    <p><strong>السبب:</strong> {{reason}}</p>
    <p><strong>تاريخ الإصدار:</strong> {{warning_date}}</p>
    <p><strong>الإجراء المتوقع:</strong> {{action_required}}</p>
</div>

<p>يرجى أخذ هذا الإشعار بعين الاعتبار والالتزام بقواعد العمل.</p>

<p>في حالة لديك أي استفسارات، يرجى التواصل مع إدارة الموارد البشرية.</p>

```

**Email Recipient:** {{to_email}}
**Email Subject:** "⚠️ إنذار رسمي"

---

## الخطوة 4: تحديث ملف اعدادات EmailJS

افتح ملف `emailjs-notifications.js` وحدّث بيانات الاعتماد:

```javascript
const EmailJSConfig = {
    serviceID: 'YOUR_SERVICE_ID',          // ← ضع Service ID هنا
    templateIDLeaveRequest: 'template_leave_request',
    templateIDLeaveApproval: 'template_leave_approval',
    templateIDMedicalReminder: 'template_medical_reminder',
    templateIDWarningIssued: 'template_warning_issued',
    publicKey: 'YOUR_PUBLIC_KEY'           // ← ضع Public Key هنا
};
```

**مثال:**
```javascript
const EmailJSConfig = {
    serviceID: 'service_abc123def456',
    templateIDLeaveRequest: 'template_leave_request',
    templateIDLeaveApproval: 'template_leave_approval',
    templateIDMedicalReminder: 'template_medical_reminder',
    templateIDWarningIssued: 'template_warning_issued',
    publicKey: 'hT5k9mN2pV8xZ1c4wQ6rL'
};
```

---

## الخطوة 5: تأكد من أن قاعدة البيانات تحتوي على بريد المديرين

نظام الإشعارات يحتاج إلى:
- بريد الموظف في جدول `employees` (حقل `email`)
- معرّف المدير في جدول `employees` (حقل `manager_id`)
- بريد المدير في نفس جدول `employees`

**استعلام SQL للتحقق:**
```sql
SELECT employee_id, name, email, manager_id FROM employees LIMIT 10;
```

---

## الخطوة 6: الاختبار

1. افتح صفحة `hr-management.html` في المتصفح
2. افتح **Developer Console** (F12)
3. قم بإجراء أحد الإجراءات التالية:
   - تقديم طلب إجازة جديد
   - موافقة/رفض طلب إجازة
   - إصدار إنذار
   - عرض تنبيه انتهاء موعد الشهادة الطبية

4. تحقق من Console بحثًا عن الرسائل:
   - ✅ "EmailJS initialized successfully"
   - ✅ "Leave request notification sent to employee"
   - ✅ "Leave request notification sent to manager"

5. تحقق من بريدك الإلكتروني والمدير للبريد الجديد

---

## استكشاف الأخطاء

### المشكلة: "EmailJS library not loaded"
- **الحل:** تأكد من أن `<script async src="https://cdn.jsdelivr.net/npm/@emailjs/browser@4...">` موجود في `<head>`

### المشكلة: "Email not sent"
- **تحقق من:**
  1. Service ID و Public Key صحيحة في `emailjs-notifications.js`
  2. Templates لها ID صحيح
  3. حقول البريد موجودة في جدول `employees`
  4. Gmail للخدمة مفعّل بشكل صحيح

### المشكلة: "Could not fetch emails for notification"
- **تحقق من:**
  1. الموظف له بريد في جدول `employees`
  2. المدير محفوظ مع `manager_id`
  3. المدير له بريد في جدول `employees`

---

## المتغيرات المتاحة في النماذج

| المتغير | الوصف |
|---------|-------|
| `{{to_name}}` | اسم المستقبل (الموظف أو المدير) |
| `{{to_email}}` | بريد المستقبل |
| `{{leave_type}}` | نوع الإجازة |
| `{{from_date}}` | تاريخ البداية |
| `{{to_date}}` | تاريخ النهاية |
| `{{days_count}}` | عدد الأيام |
| `{{reason}}` | سبب الإجازة |
| `{{approval_status}}` | الحالة (موافق عليه / مرفوض) |
| `{{approver_notes}}` | ملاحظات الموافقة |
| `{{days_left}}` | أيام متبقية |
| `{{warning_type}}` | نوع الإنذار |
| `{{warning_number}}` | رقم الإنذار |

---

## نصائح الأمان

1. **لا تضع بيانات الاعتماد في الكود العام** - استخدم متغيرات البيئة في الإنتاج
2. **استخدم Gmail 2FA** - فعّل المصادقة الثنائية لحسابك
3. **قيود الرسائل** - EmailJS له حد أقصى للرسائل، تحقق من الخطة

---

## للمزيد من المعلومات

- [EmailJS Documentation](https://www.emailjs.com/docs/)
- [EmailJS Templates](https://www.emailjs.com/docs/tutorial/creating-email-template/)
- [EmailJS SDK Reference](https://www.emailjs.com/docs/sdk/send/)
