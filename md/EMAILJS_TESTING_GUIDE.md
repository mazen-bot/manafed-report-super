# اختبار نظام الإشعارات البريدية - Testing Guide

## اختبار سريع

### الخطوة 1: تحديث البيانات الأساسية
تأكد من تحديث هذا القسم في ملف `emailjs-notifications.js`:

```javascript
const EmailJSConfig = {
    serviceID: 'service_YOUR_ID_HERE',
    templateIDLeaveRequest: 'template_leave_request',
    templateIDLeaveApproval: 'template_leave_approval',
    templateIDMedicalReminder: 'template_medical_reminder',
    templateIDWarningIssued: 'template_warning_issued',
    publicKey: 'YOUR_PUBLIC_KEY_HERE'
};
```

### الخطوة 2: اختبار الاتصال بـ EmailJS
افتح console المتصفح (F12) وشغّل هذا الكود:

```javascript
// اختبار تهيئة EmailJS
setTimeout(() => {
    console.log('EmailJS initialized:', typeof emailjs !== 'undefined');
    console.log('Notification functions available:', {
        leaveRequest: typeof sendLeaveRequestNotification !== 'undefined',
        approval: typeof sendLeaveApprovalNotification !== 'undefined',
        medical: typeof sendMedicalDeadlineReminder !== 'undefined',
        warning: typeof sendWarningNotification !== 'undefined'
    });
}, 1000);
```

**النتيجة المتوقعة:**
```
EmailJS initialized: true
Notification functions available: {
    leaveRequest: true
    approval: true
    medical: true
    warning: true
}
```

### الخطوة 3: اختبار إرسال بريد مباشر
في console، اختبر إرسال بريد تجريبي:

```javascript
// اختبار مباشر
if (typeof sendCustomEmail !== 'undefined') {
    sendCustomEmail(
        'your-email@example.com',  // بريدك
        'Your Name',
        'template_leave_request',
        {
            employee_name: 'أحمد حسن',
            leave_type: 'إجازة سنوية',
            from_date: '2024-03-01',
            to_date: '2024-03-05',
            days_count: 5,
            reason: 'إجازة عادية',
            request_date: new Date().toLocaleDateString('ar-EG')
        }
    );
}
```

---

## عملية اختبار شاملة

### اختبار 1: تقديم طلب إجازة
1. سجّل الدخول كموظف
2. اذهب إلى قسم "طلب إجازة"
3. ملء النموذج وانقر **تقديم الطلب**
4. **تحقق من:**
   - ✅ ظهور رسالة النجاح في النظام
   - ✅ وصول بريد للموظف والمدير
   - ✅ ظهور في Console: "Leave request notification sent"

---

### اختبار 2: موافقة على الإجازة
1. سجّل الدخول كمسؤول/مدير
2. اذهب إلى "عرض جميع الطلبات"
3. ابحث عن طلب معليق واضغط **قبول**
4. **تحقق من:**
   - ✅ ظهور رسالة النجاح
   - ✅ وصول بريد "موافقة على الإجازة" للموظف والمدير
   - ✅ تغيير حالة الطلب إلى "موافق عليه"

---

### اختبار 3: رفض الإجازة
1. سجّل الدخول كمسؤول/مدير
2. اذهب إلى "عرض جميع الطلبات"
3. ابحث عن طلب معليق واضغط **رفض**
4. **تحقق من:**
   - ✅ ظهور رسالة النجاح
   - ✅ وصول بريد "رفض الإجازة" للموظف والمدير
   - ✅ تغيير حالة الطلب إلى "مرفوض"

---

### اختبار 4: تنبيه انتهاء موعد الشهادة الطبية
1. قدّم إجازة مرضية جديدة
2. انتظر يوم أو اثنين (أو عدّل التاريخ في قاعدة البيانات)
3. اذهب لقسم "الشهادات الطبية"
4. **تحقق من:**
   - ✅ ظهور تنبيه "يوم واحد متبقي" أو ما شابه
   - ✅ وصول بريد تنبيه للموظف والمدير
   - ✅ ظهور في Console: "Medical deadline reminder sent"

---

### اختبار 5: إصدار إنذار
1. سجّل الدخول كمسؤول/مدير
2. اذهب إلى قسم "الإنذارات"
3. اختر موظف وملء النموذج، اضغط **إضافة الإنذار**
4. **تحقق من:**
   - ✅ ظهور رسالة النجاح
   - ✅ وصول بريد "إنذار رسمي" للموظف والمدير
   - ✅ ظهور في Console: "Warning notification sent"

---

## فحص السجلات

### في Developer Console (F12):
ابحث عن هذه الرسائل الناجحة:
```
✅ EmailJS initialized successfully
✅ Leave request notification sent to employee
✅ Leave request notification sent to manager
✅ Approval notification success
✅ Warning notification sent
```

### رسائل الخطأ الشائعة:
```
❌ EmailJS library not loaded
❌ Error fetching employee/manager emails
❌ Error sending email notification
```

---

## كيفية قراءة الأخطاء

عند حدوث خطأ، سيظهر في Console شيء مثل:
```javascript
{
  status: 400,
  text: "Invalid 'to_email' parameter"
}
```

**الحلول الشائعة:**
- تحقق من Service ID و Public Key
- تأكد من Template ID صحيح
- تحقق من وجود {{to_email}} في Template
- تأكد من وجود بريد الموظف في قاعدة البيانات

---

## نصائح للاختبار

1. **استخدم بريدك الشخصي** للاختبارات الأولى
2. **فعّل "إظهار البريد الجديد"** في Gmail لعدم فقدان الرسائل
3. **تحقق من مجلد Spam** - قد تذهب الرسائل الأولى هناك
4. **استخدم المتصفح نفسه** - لا تغير متصفح/جهاز أثناء الاختبار

---

## تعطيل الإشعارات مؤقتًا

إذا أردت تعطيل الإشعارات مؤقتًا أثناء الاختبار، علّق هذه الأسطر في `hr-management.html`:

```javascript
// قبل التعديل:
if (window.sendLeaveRequestNotification) {
    sendLeaveRequestNotification(requestData);
}

// بعد التعليق:
// if (window.sendLeaveRequestNotification) {
//     sendLeaveRequestNotification(requestData);
// }
```

---

## دعم إضافي

إذا واجهت مشكلة:
1. افتح **Chrome DevTools** (F12)
2. اذهب إلى **Console** tab
3. ابحث عن الأخطاء الحمراء
4. انسخ رسالة الخطأ وتحقق من EMAILJS_SETUP_GUIDE.md

---

## نموذج التقرير

عند التواصل للحصول على الدعم، قدم هذه المعلومات:
- ✓ الإجراء الذي قمت به (مثل: تقديم إجازة)
- ✓ رسالة الخطأ من Console
- ✓ ما إذا كان EmailJS مهيأ بشكل صحيح
- ✓ ما إذا كان الموظف لديه بريد في النظام
