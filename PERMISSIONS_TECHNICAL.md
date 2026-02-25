# 💻 دليل البرمجة - نظام الصلاحيات التقني

## 📖 نظرة عامة تقنية

تم تطوير نظام صلاحيات متقدم يعتمد على قائمة الصلاحيات (Permissions Array) المخزنة مع بيانات الموظف في قاعدة البيانات.

---

## 🏗️ البنية الأساسية

### كائن المستخدم الحالي (currentUser)

```javascript
currentUser = {
    id: "emp_id",
    employee_id: "1012",
    name: "أحمد علي",
    branch_id: "branch_1",
    branch_name: "السامر",
    permissions: ["viewReports", "addSales", "editSales", "export"]
}
```

### قاموس وصف الصلاحيات

```javascript
PERMISSIONS_DESCRIPTION = {
    'viewReports': { label: '👁️ عرض التقارير', description: '...' },
    'addSales': { label: '➕ إضافة مبيعات', description: '...' },
    'editSales': { label: '✏️ تعديل مبيعات', description: '...' },
    // ... 13 صلاحية كاملة
}
```

---

## ✅ دوال التحقق من الصلاحيات

### 1️⃣ التحقق من صلاحية واحدة
```javascript
hasPermission(permission)
```

**الاستخدام**:
```javascript
if (hasPermission('editSales')) {
    // فعّل خاصية التعديل
    editButton.style.display = 'block';
}
```

**الكود الداخلي**:
```javascript
function hasPermission(permission) {
    if (!currentUser) return false;
    if (!Array.isArray(currentUser.permissions)) return false;
    return currentUser.permissions.includes(permission);
}
```

---

### 2️⃣ التحقق من جميع الصلاحيات (AND Logic)
```javascript
hasAllPermissions(...permissions)
```

**الاستخدام**:
```javascript
if (hasAllPermissions('editSales', 'export')) {
    // السماح بالعمليات المتقدمة
}
```

**الكود الداخلي**:
```javascript
function hasAllPermissions(...permissions) {
    return permissions.every(p => hasPermission(p));
}
```

---

### 3️⃣ التحقق من أي صلاحية (OR Logic)
```javascript
hasAnyPermission(...permissions)
```

**الاستخدام**:
```javascript
if (hasAnyPermission('manageEmployees', 'manageBranches')) {
    // عرض قسم إداري
}
```

**الكود الداخلي**:
```javascript
function hasAnyPermission(...permissions) {
    return permissions.some(p => hasPermission(p));
}
```

---

## 🚨 رسائل الرفض

### دالة عرض رسالة عدم الصلاحية
```javascript
showNoPermissionMessage(action = 'هذا الإجراء')
```

**الاستخدام**:
```javascript
if (!hasPermission('deleteSales')) {
    showNoPermissionMessage('حذف السجلات');
    return;
}
```

**الكود الداخلي**:
```javascript
function showNoPermissionMessage(action = 'هذا الإجراء') {
    showCustomError(
        `ليس لديك صلاحية لـ ${action}. تواصل مع الإدارة لتفعيل هذه الميزة.`,
        '⛔ صلاحية غير كافية'
    );
}
```

---

## 🎨 تحديث واجهة المستخدم

### دالة تحديث الواجهة حسب الصلاحيات
```javascript
updateUIByPermissions()
```

**الاستخدام**:
```javascript
// بعد تسجيل الدخول مباشرة
currentUser = userData;
updateUIByPermissions(); // تحديث الواجهة
```

**الوظائف**:
1. إظهار/إخفاء الأزرار حسب الصلاحيات
2. تفعيل/تعطيل الميزات
3. إخفاء البيانات الحساسة
4. تكوين قوائم التصفية

---

## 🔌 نقاط التطبيق في الكود

### 1. في دالة deleteRecord
```javascript
async function deleteRecord(id) {
    // 1. التحقق من صلاحية حذف المبيعات
    if (!hasPermission('deleteSales')) {
        showNoPermissionMessage('حذف السجلات');
        return;
    }
    
    // 2. التحقق من صلاحية إدارة الموظفين (شرط إضافي)
    if (!currentUser || !currentUser.permissions.includes('manageEmployees')) {
        showCustomError('ليس لديك صلاحية حذف السجلات...', 'صلاحية غير كافية');
        return;
    }
    
    // 3. متابعة العملية
    const confirmed = await confirm('هل أنت متأكد...?');
    // ...
}
```

### 2. في دالة saveEditedReport
```javascript
async function saveEditedReport() {
    // التحقق من صلاحية تعديل المبيعات
    if (!hasPermission('editSales')) {
        showNoPermissionMessage('تعديل السجلات');
        return;
    }
    // ... باقي الدالة
}
```

### 3. في دالة downloadBackup
```javascript
function downloadBackup() {
    // التحقق من صلاحية النسخ الاحتياطية
    if (!hasPermission('backup')) {
        showNoPermissionMessage('إنشاء نسخ احتياطية');
        return;
    }
    // ... تنفيذ الدالة
}
```

### 4. في دالة exportToExcel
```javascript
function exportToExcel() {
    // التحقق من صلاحية التصدير
    if (!hasPermission('export')) {
        showNoPermissionMessage('تصدير البيانات');
        return;
    }
    // ... تنفيذ التصدير
}
```

---

## 📊 نموذج تدفق التحقق من الصلاحيات

```
START
  ↓
تسجيل الدخول
  ↓
جلب بيانات الموظف + الصلاحيات من Supabase
  ↓
تخزين الصلاحيات في currentUser.permissions[]
  ↓
عند الضغط على أي زر/ميزة
  ↓
استدعاء hasPermission('صلاحية')
  ↓
هل توجد الصلاحية في الـ array؟
  ├─ YES → فعّل العملية ✅
  └─ NO  → عرض رسالة الرفض ❌
  ↓
END
```

---

## 🗄️ تخزين الصلاحيات في Supabase

### جدول employees
```sql
-- الحقول الأساسية
id              | PRIMARY KEY
employee_id     | TEXT UNIQUE
name            | TEXT
password        | TEXT
branch_id       | FOREIGN KEY
branch_name     | TEXT

-- حقل الصلاحيات
permissions     | TEXT[] (PostgreSQL array) أو JSON
              | مثال: ["viewReports", "addSales", "editSales"]
```

### مثال على التخزين:
```json
{
  "id": 1,
  "employee_id": "1012",
  "name": "أحمد علي",
  "permissions": ["viewReports", "addSales", "editSales", "export"],
  "branch_id": 2,
  "branch_name": "السامر"
}
```

---

## 🔄 تحديث الصلاحيات

### في admin.html - دالة savePermissionsChanges
```javascript
async function savePermissionsChanges(empId) {
    // جمع الصلاحيات المختارة
    const selectedPerms = Array.from(
        modal.querySelectorAll('input[type="checkbox"]:checked')
    ).map(c => c.value);
    
    // حفظ في Supabase
    const { error } = await supabase
        .from('employees')
        .update({ permissions: selectedPerms })
        .eq('id', empId);
    
    if (error) throw error;
    
    showCustomSuccess('تم حفظ الصلاحيات بنجاح');
}
```

---

## 📱 عرض قائمة الموظفين مع صلاحياتهم

### دالة loadEmployeesPermissionsManagement
```javascript
async function loadEmployeesPermissionsManagement() {
    // 1. جلب قائمة الموظفين
    const { data: employees } = await supabase
        .from('employees')
        .select('*')
        .order('name', { ascending: true });
    
    // 2. عرض جدول يوضح صلاحيات كل موظف
    // 3. إضافة أزرار تعديل وإعادة تعيين
}
```

---

## 🎯 الحالات الخاصة والمتطلبات المزدوجة

### حذف السجل يتطلب صلاحيتين
```javascript
if (!hasPermission('deleteSales')) {
    showNoPermissionMessage('حذف السجلات');
    return;
}

if (!currentUser.permissions.includes('manageEmployees')) {
    showCustomError('فقط المديرون يمكنهم حذف السجلات...', '...');
    return;
}
```

### التبرير: حماية إضافية ضد الحذف العرضي

---

## 🛡️ أفضل الممارسات البرمجية

### ✅ افعل هذا:
```javascript
// فحص واضح ومبكر
if (!hasPermission('editSales')) {
    showNoPermissionMessage('تعديل السجلات');
    return;
}

// استخدم رسائل وصفية
showCustomError('ليس لديك صلاحية...', '⛔ صلاحية غير كافية');

// وثق الصلاحيات المطلوبة
// التحقق من الصلاحية: editSales
```

### ❌ لا تفعل هذا:
```javascript
// فحص متأخر في الدالة
// try { ... } catch (err) { ... }

// رسائل غير واضحة
// بدلاً من: showNoPermissionMessage('تعديل السجلات')
// لا تكتب: alert('خطأ في العملية');

// لا توثق الصلاحيات المطلوبة
```

---

## 🧪 اختبار الصلاحيات

### اختبار يدوي:
```javascript
// في console المتصفح
console.log(currentUser.permissions); // اعرض الصلاحيات الحالية
console.log(hasPermission('editSales')); // اختبر صلاحية واحدة
```

### حالات الاختبار:
1. ✅ مستخدم بدون صلاحيات
2. ✅ مستخدم بصلاحيات محدودة
3. ✅ مستخدم بكل الصلاحيات
4. ✅ تحديث الصلاحيات فوراً بعد الحفظ

---

## 📝 إضافة صلاحية جديدة

### الخطوات:
1. **أضفها إلى قاموس PERMISSIONS_DESCRIPTION**:
```javascript
'newPermission': { 
    label: '🆕 صلاحية جديدة', 
    description: 'وصف مفصل...' 
}
```

2. **أضفها إلى قائمة الصلاحيات في admin.html**:
```html
<label class="perm-item">
    <input type="checkbox" value="newPermission"> 
    🆕 صلاحية جديدة
</label>
```

3. **استخدمها في reports.html**:
```javascript
if (!hasPermission('newPermission')) {
    showNoPermissionMessage('...');
    return;
}
```

4. **اختبرها**:
```javascript
// في console
hasPermission('newPermission');
```

---

## 🔗 الملفات ذات الصلة

| الملف | الموقع | الدور |
|------|--------|------|
| admin.html | `/admin.html` | إدارة الصلاحيات للموظفين |
| reports.html | `/reports.html` | تطبيق الصلاحيات على الميزات |
| PERMISSIONS_GUIDE.md | `/PERMISSIONS_GUIDE.md` | دليل المستخدم |

---

## 🚀 خارطة الطريق المستقبلية

- [ ] تسجيل العمليات الحساسة (Audit Log)
- [ ] آثار التفتيش (Audit Trail) للصلاحيات
- [ ] صلاحيات مبنية على المستويات (Role-Based)
- [ ] مدة صلاحيات مؤقتة (Temporary Permissions)
- [ ] صلاحيات موقوتة (Time-Based Permissions)

---

**الإصدار**: 2.0  
**آخر تحديث**: فبراير 2026  
**الحالة**: مستقر وجاهز للإنتاج ✅
