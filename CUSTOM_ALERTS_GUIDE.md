# 📢 دليل نظام التنبيهات المخصصة

## نظرة عامة

تم استبدال رسائل التنبيهات القياسية من المتصفح (alert, confirm, prompt) برسائل جذابة وموحدة متطابقة مع تصميم الموقع.

## المميزات ✨

- ✅ **نماذج جذابة وحديثة** - تصميم احترافي يتطابق مع الموقع
- ✅ **تنبيهات بألوان مختلفة** - أحمر للأخطاء، أخضر للنجاح، برتقالي للتحذيرات
- ✅ **رسوم توضيحية** - أيقونات تعبيرية لكل نوع تنبيه
- ✅ **تأثيرات حركية سلسة** - انتقالات احترافية عند الظهور والاختفاء
- ✅ **دعم اللغة العربية الكامل** - واجهة كاملة بالعربية من اليمين لليسار
- ✅ **متوافق مع جميع الأجهزة** - يعمل على الهواتف والتابليت وأجهزة الحاسوب

## أنواع التنبيهات

### 1. تنبيهات عادية (Alert)
```javascript
await showCustomAlert('رسالة التنبيه', 'عنوان التنبيه', 'info');
```
- **النوع**: معلومة (info)
- **الأيقونة**: ℹ️
- **الألوان**: أزرق وبنفسجي

### 2. تأكيدات (Confirm)
```javascript
const result = await confirm('هل أنت متأكد من المتابعة؟');
if (result) {
    // تم التأكيد
}
```
- **العودة**: يعيد `true` أو `false`
- **الأيقونة**: ❓
- **الأزرار**: "نعم، متأكد" و "إلغاء"

### 3. نماذج الإدخال (Prompt)
```javascript
const userInput = await prompt('أدخل اسمك:', 'القيمة الافتراضية');
if (userInput !== null) {
    // تم الإدخال
}
```
- **العودة**: يعيد النص المدخل أو `null`
- **الأيقونة**: ✏️

### 4. إشعارات النجاح (Toast - Success)
```javascript
showCustomSuccess('تم الحفظ بنجاح', 'تم');
```
- **المدة**: 4 ثواني
- **الأيقونة**: ✅
- **الألوان**: أخضر

### 5. إشعارات الخطأ (Toast - Error)
```javascript
showCustomError('حدث خطأ في الحفظ', 'خطأ');
```
- **المدة**: 4.5 ثواني
- **الأيقونة**: ❌
- **الألوان**: أحمر

### 6. إشعارات التحذير (Toast - Warning)
```javascript
showCustomWarning('تأكد من البيانات المدخلة', 'تحذير');
```
- **المدة**: 4 ثواني
- **الأيقونة**: ⚠️
- **الألوان**: برتقالي

### 7. إشعارات معلومات (Toast - Info)
```javascript
showCustomInfo('عملية قيد المعالجة...', 'معلومة');
```
- **المدة**: 3.5 ثواني
- **الأيقونة**: ℹ️
- **الألوان**: أزرق

## استخدام الدوال العامة

### تجاوز الدوال القياسية
تم تجاوز الدوال القياسية للمتصفح بحيث يمكن استخدامها مباشرة:

```javascript
// بدلاً من:
alert('مرحباً');
// الآن:
alert('مرحباً'); // سيستخدم showCustomAlert تلقائياً
```

```javascript
// بدلاً من:
if (confirm('هل تريد المتابعة؟')) {
    // ...
}
// الآن:
if (await confirm('هل تريد المتابعة؟')) {
    // ...
}
```

## الملفات المطلوبة

1. **custom-alerts.js** - نظام التنبيهات الأساسي
   - يحتوي على جميع الدوال والتصاميم
   - يجب تحميله قبل أي كود يستخدم التنبيهات

2. **override-alerts.js** - تجاوز الدوال القياسية
   - يجب تحميله بعد `custom-alerts.js`
   - يسمح باستخدام `alert()` و `confirm()` بشكل مباشر

## كيفية الدمج

تأكد من وجود هاتين السطرين في `<head>` لكل صفحة:

```html
<script src="custom-alerts.js"></script>
<script src="override-alerts.js"></script>
```

**الترتيب مهم**: يجب تحميل `custom-alerts.js` قبل `override-alerts.js`.

## أمثلة عملية

### مثال 1: تأكيد الحذف
```javascript
async function deleteItem(itemId) {
    const confirmed = await confirm('هل أنت متأكد من حذف هذا العنصر؟');
    if (confirmed) {
        // عملية الحذف
        showCustomSuccess('تم الحذف بنجاح');
    }
}
```

### مثال 2: التحقق من البيانات
```javascript
async function saveForm(formData) {
    if (!formData.name) {
        showCustomError('أدخل الاسم من فضلك');
        return;
    }
    
    if (!formData.email) {
        showCustomError('أدخل البريد الإلكتروني من فضلك');
        return;
    }
    
    // إجراء الحفظ
    try {
        await saveData(formData);
        showCustomSuccess('تم الحفظ بنجاح', 'تم');
    } catch (error) {
        showCustomError('حدث خطأ: ' + error.message, 'خطأ');
    }
}
```

### مثال 3: طلب إدخال من المستخدم
```javascript
async function askForComment() {
    const comment = await prompt('أدخل تعليقك:', '');
    if (comment !== null && comment.trim()) {
        showCustomInfo('تم استلام تعليقك', 'شكراً');
    }
}
```

## التخصيص

### تغيير الألوان
عدّل متغيرات CSS في `custom-alerts.js`:

```javascript
:root {
    --custom-primary: #6b2d87;
    --custom-success: #4caf50;
    --custom-error: #f44336;
    --custom-warning: #ff9800;
    --custom-info: #2196f3;
}
```

### تغيير الأيقونات
عدّل الأيقونات في دوال العرض:

```javascript
const icons = {
    info: 'ℹ️',     // غير هنا
    success: '✅',   // أو هنا
    error: '❌',
    warning: '⚠️'
};
```

## ملاحظات مهمة

⚠️ **الـ async/await مطلوب**: بما أن التنبيهات الآن تعود Promises، يجب استخدام `await` أو `.then()`:

```javascript
// ✅ صحيح
const result = await confirm('هل تريد المتابعة؟');

// ❌ خطأ
const result = confirm('هل تريد المتابعة؟');
console.log(result); // سيطبع Promise وليس boolean
```

## المتصفحات المدعومة

- ✅ Chrome
- ✅ Firefox
- ✅ Safari
- ✅ Edge
- ✅ أي متصفح حديث يدعم ES6

## استكشاف الأخطاء

### المشكلة: التنبيهات لا تظهر
**الحل**: تأكد من تحميل `custom-alerts.js` و `override-alerts.js` في الترتيب الصحيح

### المشكلة: الرسالة تظهر لثانية واحدة فقط
**الحل**: هذا صحيح للـ toasts - استخدم `showCustomAlert()` بدلاً منها للرسائل الطويلة

### المشكلة: الأسلوب غير صحيح
**الحل**: تحقق من أن ملف CSS لم يتم منعه أو حذفه

## الدعم والمساعدة

للمزيد من المعلومات أو الإبلاغ عن مشاكل، راجع الملفات:
- `custom-alerts.js` - التعليقات والتوثيق الكامل
- `override-alerts.js` - دوال التجاوز

---

**آخر تحديث**: 24 فبراير 2026
**الإصدار**: 1.0
