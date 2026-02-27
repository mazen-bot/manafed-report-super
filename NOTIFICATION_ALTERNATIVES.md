# 🚀 بدائل مجانية لنظام الإشعارات

## 📊 مقارنة بين الخيارات المجانية

| الخيار | التكلفة | الحد الأقصى | سهولة التطبيق | التوصية |
|--------|---------|-------------|---------------|----------|
| **Telegram Bot** ⭐ | مجاني 100% | غير محدود | سهل جداً | **الأفضل** |
| EmailJS (الحالي) | مجاني | 200 إيميل/شهر | سهل | محدود |
| Firebase FCM | مجاني 100% | غير محدود | متوسط | جيد |
| Web Push Notifications | مجاني 100% | غير محدود | متوسط | جيد |
| نظام داخلي في الموقع | مجاني 100% | غير محدود | سهل | محدود الفائدة |
| Discord Webhook | مجاني 100% | غير محدود | سهل | غير مناسب للعمل |

---

## ⭐ الحل الموصى به: Telegram Bot

### لماذا Telegram Bot هو الأفضل؟

✅ **مجاني تماماً** - بدون أي تكاليف أو حدود  
✅ **عدد رسائل غير محدود** - أرسل ملايين الرسائل  
✅ **سهل جداً** - API بسيط ومباشر  
✅ **سريع** - الرسائل تصل فوراً (1-2 ثانية)  
✅ **يعمل على كل الأجهزة** - هاتف، كمبيوتر، ويب  
✅ **منتشر** - معظم الناس عندهم تليجرام  
✅ **آمن** - تشفير قوي  
✅ **رسائل غنية** - نص، أزرار، صور، ملفات  
✅ **لا يحتاج تطبيق منفصل** - الكل عنده تليجرام  

---

## 🔧 كيفية تطبيق Telegram Bot

### الخطوة 1: إنشاء Bot

1. افتح Telegram وابحث عن: `@BotFather`
2. أرسل: `/newbot`
3. اختر اسم للبوت (مثل: ManafedHRBot)
4. اختر username (مثل: manafed_hr_bot)
5. ستحصل على **Bot Token** مثل:
   ```
   5847362819:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw
   ```
6. احفظ هذا Token!

### الخطوة 2: الحصول على Chat ID للموظفين

كل موظف يحتاج:
1. فتح البوت في تليجرام (https://t.me/manafed_hr_bot)
2. الضغط على "Start" أو إرسال `/start`
3. سيحصل على Chat ID

**طريقة سهلة للحصول على Chat ID:**
أرسل أي رسالة للبوت، ثم افتح:
```
https://api.telegram.org/bot<BOT_TOKEN>/getUpdates
```
ستجد Chat ID في النتيجة.

### الخطوة 3: إضافة Chat ID للموظفين

في admin.html، أضف عمود جديد للـ Chat ID:

```sql
-- إضافة عمود telegram_chat_id
ALTER TABLE employees
ADD COLUMN IF NOT EXISTS telegram_chat_id TEXT;

-- مثال: تحديث Chat ID لموظف
UPDATE employees
SET telegram_chat_id = '123456789'
WHERE employee_id = 'E001';
```

---

## 💻 الكود الجاهز

### ملف جديد: `telegram-notifications.js`

```javascript
// Telegram Bot Configuration
const TelegramConfig = {
    botToken: '5847362819:AAHdqTcvCH1vGWJxfSeofSAs0K5PALDsaw', // ضع Bot Token هنا
    apiUrl: 'https://api.telegram.org/bot'
};

// إرسال رسالة تليجرام
async function sendTelegramMessage(chatId, message) {
    try {
        const url = `${TelegramConfig.apiUrl}${TelegramConfig.botToken}/sendMessage`;
        
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                chat_id: chatId,
                text: message,
                parse_mode: 'HTML' // يدعم تنسيق HTML
            })
        });

        const result = await response.json();
        
        if (result.ok) {
            console.log('✅ Telegram message sent successfully');
            return true;
        } else {
            console.error('❌ Telegram error:', result.description);
            return false;
        }
    } catch (error) {
        console.error('❌ Error sending Telegram message:', error);
        return false;
    }
}

// جلب Chat ID من قاعدة البيانات
async function getTelegramChatIds(employeeId) {
    const supabase = window.supabaseInstance;
    
    try {
        // جلب بيانات الموظف
        const { data: employee, error: empError } = await supabase
            .from('employees')
            .select('employee_id, name, telegram_chat_id, manager_id')
            .eq('employee_id', employeeId)
            .single();

        if (empError || !employee) {
            console.error('Employee not found:', employeeId);
            return null;
        }

        let managerChatId = null;
        let managerName = null;

        // جلب Chat ID للمدير إذا كان موجود
        if (employee.manager_id) {
            const { data: manager, error: mgrError } = await supabase
                .from('employees')
                .select('employee_id, name, telegram_chat_id')
                .eq('employee_id', employee.manager_id)
                .single();

            if (!mgrError && manager) {
                managerChatId = manager.telegram_chat_id;
                managerName = manager.name;
            }
        }

        return {
            employeeChatId: employee.telegram_chat_id,
            employeeName: employee.name,
            managerChatId: managerChatId,
            managerName: managerName
        };
    } catch (error) {
        console.error('Error fetching Telegram chat IDs:', error);
        return null;
    }
}

// إشعار طلب إجازة جديد (للمدير)
async function sendLeaveRequestTelegram(leaveData) {
    try {
        const chatIds = await getTelegramChatIds(leaveData.employee_id);
        
        if (!chatIds || !chatIds.managerChatId) {
            console.warn('⚠️ No manager Telegram chat ID found');
            return false;
        }

        const message = `
🔔 <b>طلب إجازة جديد</b>

👤 <b>الموظف:</b> ${chatIds.employeeName}
📋 <b>النوع:</b> ${leaveData.leave_type || 'إجازة'}
📅 <b>من:</b> ${leaveData.from_date}
📅 <b>إلى:</b> ${leaveData.to_date}
🔢 <b>الأيام:</b> ${leaveData.days_count}
📝 <b>السبب:</b> ${leaveData.reason || 'بدون تفاصيل'}

⏰ <b>تاريخ الطلب:</b> ${new Date().toLocaleDateString('ar-EG')}

يرجى مراجعة الطلب من نظام إدارة الموارد البشرية.
        `.trim();

        return await sendTelegramMessage(chatIds.managerChatId, message);
    } catch (error) {
        console.error('❌ Error sending leave request Telegram:', error);
        return false;
    }
}

// إشعار الموافقة/الرفض (للموظف)
async function sendLeaveApprovalTelegram(leaveData, approvalStatus, approverNotes = '') {
    try {
        const chatIds = await getTelegramChatIds(leaveData.employee_id);
        
        if (!chatIds || !chatIds.employeeChatId) {
            console.warn('⚠️ No employee Telegram chat ID found');
            return false;
        }

        const statusEmoji = approvalStatus === 'approved' ? '✅' : '❌';
        const statusText = approvalStatus === 'approved' ? 'تمت الموافقة' : 'تم الرفض';

        const message = `
${statusEmoji} <b>${statusText} على طلب الإجازة</b>

👤 <b>عزيزي:</b> ${chatIds.employeeName}

📋 <b>النوع:</b> ${leaveData.leave_type || 'إجازة'}
📅 <b>من:</b> ${leaveData.from_date}
📅 <b>إلى:</b> ${leaveData.to_date}

${statusEmoji} <b>الحالة:</b> ${statusText}

📝 <b>ملاحظات:</b> ${approverNotes || 'لا توجد ملاحظات'}

⏰ <b>تاريخ الرد:</b> ${new Date().toLocaleDateString('ar-EG')}
        `.trim();

        return await sendTelegramMessage(chatIds.employeeChatId, message);
    } catch (error) {
        console.error('❌ Error sending approval Telegram:', error);
        return false;
    }
}

// إشعار تذكير الشهادة الطبية (للموظف)
async function sendMedicalReminderTelegram(leaveData, daysLeft) {
    try {
        const chatIds = await getTelegramChatIds(leaveData.employee_id);
        
        if (!chatIds || !chatIds.employeeChatId) {
            console.warn('⚠️ No employee Telegram chat ID found');
            return false;
        }

        const message = `
⚠️ <b>تذكير: الشهادة الطبية مطلوبة</b>

👤 <b>عزيزي:</b> ${chatIds.employeeName}

📋 نوع الإجازة: إجازة مرضية
📅 من: ${leaveData.from_date}
📅 إلى: ${leaveData.to_date}

⏰ <b>المدة المتبقية:</b> ${daysLeft} يوم

📎 يرجى رفع الشهادة الطبية قبل انتهاء المهلة.

يمكنك رفعها من نظام إدارة الموارد البشرية.
        `.trim();

        return await sendTelegramMessage(chatIds.employeeChatId, message);
    } catch (error) {
        console.error('❌ Error sending medical reminder Telegram:', error);
        return false;
    }
}

// إشعار إنذار جديد (للموظف)
async function sendWarningTelegram(employeeId, warningData) {
    try {
        const chatIds = await getTelegramChatIds(employeeId);
        
        if (!chatIds || !chatIds.employeeChatId) {
            console.warn('⚠️ No employee Telegram chat ID found');
            return false;
        }

        const message = `
⚠️ <b>إشعار: إنذار جديد</b>

👤 <b>عزيزي:</b> ${chatIds.employeeName}

📋 <b>نوع الإنذار:</b> ${warningData.warning_level}
📝 <b>السبب:</b> ${warningData.reason}
👔 <b>من:</b> ${warningData.issued_by_name}

⏰ <b>التاريخ:</b> ${new Date().toLocaleDateString('ar-EG')}

يرجى مراجعة الإنذار والاطلاع عليه من نظام إدارة الموارد البشرية.
        `.trim();

        return await sendTelegramMessage(chatIds.employeeChatId, message);
    } catch (error) {
        console.error('❌ Error sending warning Telegram:', error);
        return false;
    }
}

console.log('✅ Telegram notifications module loaded');
```

---

## 📝 التطبيق في hr-management.html

أضف بعد تحميل emailjs-notifications.js:

```html
<!-- Telegram Notifications -->
<script src="telegram-notifications.js"></script>

<script>
    // عند رفع طلب إجازة
    async function submitLeaveRequest(leaveData) {
        // ... الكود الموجود ...
        
        // إرسال إشعار تليجرام للمدير
        if (window.sendLeaveRequestTelegram) {
            sendLeaveRequestTelegram(leaveData).catch(err => {
                console.warn('⚠️ Could not send Telegram notification:', err);
            });
        }
    }
    
    // عند الموافقة/الرفض
    async function updateRequestStatus(requestId, status) {
        // ... الكود الموجود ...
        
        // إرسال إشعار تليجرام للموظف
        if (window.sendLeaveApprovalTelegram && leaveRequest) {
            sendLeaveApprovalTelegram(leaveRequest, status).catch(err => {
                console.warn('⚠️ Could not send Telegram notification:', err);
            });
        }
    }
</script>
```

---

## 🎨 إضافة واجهة لإدخال Chat ID في admin.html

مثل ما فعلنا مع البريد الإلكتروني والمدير، نضيف عمود Chat ID:

```html
<th>Telegram Chat ID</th>

<td>
    <button onclick="editEmployeeTelegram('E001', 'أحمد', '123456789')">
        ➕ تليجرام
    </button>
</td>
```

والدالة:

```javascript
window.editEmployeeTelegram = async function(employeeId, employeeName, currentChatId) {
    const newChatId = prompt(
        `📱 تحديد Telegram Chat ID\n\nالموظف: ${employeeName}\n\nلمعرفة Chat ID:\n1. افتح البوت في تليجرام\n2. أرسل /start\n3. أرسل /myid\n\nأدخل Chat ID:`,
        currentChatId
    );
    
    if (newChatId === null) return;
    
    const { error } = await supabase
        .from('employees')
        .update({ telegram_chat_id: newChatId || null })
        .eq('employee_id', employeeId);
    
    if (!error) {
        showCustomSuccess('✅ تم تحديث Telegram Chat ID بنجاح');
        loadEmployeeEmails();
    }
};
```

---

## 🔍 كيف يحصل الموظف على Chat ID؟

### الطريقة السهلة - إضافة أمر /myid للبوت:

يمكنك إنشاء بوت بسيط يرد على `/myid` بالـ Chat ID.

أو استخدم هذا البوت الجاهز: [@userinfobot](https://t.me/userinfobot)

---

## 📊 المقارنة مع EmailJS

| الميزة | EmailJS | Telegram Bot |
|--------|---------|--------------|
| التكلفة | مجاني حتى 200 | مجاني 100% |
| الحد الأقصى | 200/شهر | غير محدود |
| سرعة الوصول | 1-5 دقائق | 1-2 ثانية |
| إشعارات فورية | ❌ | ✅ |
| يعمل على الهاتف | ✅ | ✅ |
| لا يحتاج تسجيل | ✅ | ✅ (إذا عندهم تليجرام) |
| رسائل غنية | ✅ | ✅ |
| أزرار تفاعلية | ❌ | ✅ |

---

## 🚀 حلول مجانية أخرى

### 2️⃣ Firebase Cloud Messaging (FCM)

**المميزات:**
- مجاني 100%
- عدد رسائل غير محدود
- يعمل حتى لو الموقع مغلق
- دعم Web, Android, iOS

**العيوب:**
- أعقد من Telegram
- يحتاج setup إضافي
- يحتاج Service Worker

### 3️⃣ Web Push Notifications

**المميزات:**
- مجاني 100%
- يعمل في المتصفح مباشرة
- لا يحتاج حساب خارجي

**العيوب:**
- يحتاج الموظف أن يكون فتح الموقع مرة
- قد لا يعمل على كل المتصفحات
- لا يعمل على iOS Safari بشكل جيد

### 4️⃣ نظام إشعارات داخلي

**المميزات:**
- مجاني 100%
- تحكم كامل
- بدون اعتماد على خدمة خارجية

**العيوب:**
- الموظف يجب أن يفتح الموقع ليرى الإشعار
- لا يوجد إشعارات فورية

---

## 💡 التوصية النهائية

### للاستخدام الفوري والأفضل:

**استخدم Telegram Bot** 🎯

**لماذا؟**
1. ✅ مجاني 100% بدون حدود
2. ✅ سهل جداً في التطبيق (يوم واحد)
3. ✅ الموظفون عندهم تليجرام أصلاً
4. ✅ إشعارات فورية (1-2 ثانية)
5. ✅ يعمل على الهاتف والكمبيوتر
6. ✅ رسائل غنية وواضحة

### الخطة المقترحة:

#### الأسبوع الأول:
1. إنشاء Telegram Bot
2. إضافة عمود `telegram_chat_id` للموظفين
3. كل موظف يفتح البوت ويحصل على Chat ID
4. تحديث Chat ID في النظام

#### الأسبوع الثاني:
1. تطبيق `telegram-notifications.js`
2. الربط مع `hr-management.html`
3. اختبار الإشعارات

#### بعد ذلك:
- استخدم Telegram لجميع الإشعارات
- احتفظ بـ EmailJS كـ backup (اختياري)

---

## 📞 روابط مفيدة

- [Telegram Bot API](https://core.telegram.org/bots/api)
- [BotFather](https://t.me/botfather)
- [Get Chat ID Bot](https://t.me/userinfobot)
- [Telegram Bot Examples](https://core.telegram.org/bots/samples)

---

## 🎯 الخلاصة

| الحل | الأفضل لـ | النجوم |
|------|----------|--------|
| **Telegram Bot** | الشركات والإشعارات الفورية | ⭐⭐⭐⭐⭐ |
| Firebase FCM | التطبيقات المتقدمة | ⭐⭐⭐⭐ |
| Web Push | المواقع البسيطة | ⭐⭐⭐ |
| نظام داخلي | عرض الإشعارات فقط | ⭐⭐ |
| EmailJS | البريد التقليدي | ⭐⭐ |

**النصيحة:** ابدأ بـ Telegram Bot - الأسهل والأقوى والمجاني 100%! 🚀
